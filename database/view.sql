CREATE OR REPLACE PROCEDURE zajezdy_v_terminu(
    termin_od IN DATE, 
    termin_do IN DATE,
    p_stat_id IN NUMBER,
    p_doprava_id IN NUMBER,
    p_strava_id IN NUMBER,
    pocet_radku IN NUMBER,
    radkovani_start IN NUMBER,
    zajezdy_out OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN zajezdy_out FOR
    SELECT
        z.zajezd_id,
        u.nazev AS Nazev_hotelu,
        u.pocet_hvezd AS Pocet_hvezd,
        SUBSTR(u.popis, 1, 300) as popis,
        s.nazev AS Nazev_statu,
        a.mesto,
        a.psc,
        s.stat_id as Stat_id,
        d.nazev as Doprava,
        d.doprava_id,
        st.nazev as Strava, 
        st.strava_id,
        z.cena_za_osobu AS Cena_za_osobu_plna,
        ROUND(z.cena_za_osobu - (z.cena_za_osobu * (z.sleva_procent / 100))) AS Cena_za_osobu_sleva,
        pck_utils.prvni_img_zajezdy(u.ubytovani_id) AS obrazek_ubytovani_id,
        t.od AS Termin_od,
        t.do AS Termin_do,
        COUNT(*) OVER () AS celkovy_pocet_vysledku
    FROM
        UBYTOVANI u
        JOIN ADRESA a ON u.adresa_id = a.adresa_id
        JOIN STAT s ON a.stat_id = s.stat_id
        JOIN ZAJEZD z ON u.ubytovani_id = z.ubytovani_id
        JOIN DOPRAVA d ON d.doprava_id = z.doprava_id
        JOIN STRAVA st ON st.strava_id = z.strava_id
        JOIN (
            SELECT 
                termin_id,
                od,
                do,
                zajezd_id,
                ROW_NUMBER() OVER (PARTITION BY zajezd_id ORDER BY od ASC) AS rn
            FROM 
                TERMIN
            WHERE 
                do >= termin_od AND 
                od <= termin_do
        ) t ON z.zajezd_id = t.zajezd_id AND t.rn = 1
    WHERE
        z.zobrazit = 1 AND 
        (p_stat_id IS NULL OR s.stat_id = p_stat_id) AND
        (p_doprava_id IS NULL OR d.doprava_id = p_doprava_id) AND
        (p_strava_id IS NULL OR st.strava_id = p_strava_id)
    OFFSET radkovani_start ROWS FETCH NEXT pocet_radku ROWS ONLY;
        
END;

CREATE OR REPLACE VIEW ubytovani_view AS
SELECT
    u.ubytovani_id,
    u.nazev,
    u.pocet_hvezd,
    u.popis,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev as stat_nazev,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa
FROM UBYTOVANI u
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW objednavka_view AS
SELECT
    o.objednavka_id,
    z.zakaznik_id,
    os.jmeno,
    os.prijmeni,
    os.jmeno || ' ' || os.prijmeni AS cele_jmeno,
    u.nazev as ubytovani_NAZEV,
    t.od,
    t.do,
    p.nazev as POKOJ_NAZEV,
    pl.castka,
    pl.zaplacena,
    p.pocet_mist
FROM OBJEDNAVKA o
JOIN ZAKAZNIK z ON o.zakaznik_id = z.zakaznik_id
JOIN OSOBA os ON os.osoba_id = z.osoba_id
JOIN TERMIN t ON t.termin_id = o.termin_id
JOIN ZAJEZD zaj ON zaj.zajezd_id = t.zajezd_id
JOIN UBYTOVANI u ON u.ubytovani_id = zaj.ubytovani_id
JOIN POKOJ p ON p.pokoj_id = o.pokoj_id
JOIN PLATBA pl ON pl.objednavka_id = o.objednavka_id;

CREATE OR REPLACE VIEW zajezd_sprava_view AS
SELECT
    z.zajezd_id,
    u.nazev as ubytovani_nazev,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev as stat_nazev,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa,
    z.cena_za_osobu,
    z.sleva_procent,
    d.nazev as doprava_nazev,
    st.nazev as strava_nazev,
    d.doprava_id,
    st.strava_id
FROM ZAJEZD z
JOIN UBYTOVANI u ON u.ubytovani_id = z.ubytovani_id
JOIN DOPRAVA d ON d.doprava_id = z.doprava_id
JOIN STRAVA st ON st.strava_id = z.strava_id
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW zakaznik_view AS
SELECT
    z.zakaznik_id,
    o.jmeno,
    o.prijmeni,
    o.jmeno || ' ' || o.prijmeni AS cele_jmeno,
    pu.jmeno as prihlasovaci_jmeno,
    k.email,
    k.telefon,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev AS stat_nazev,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa
    
FROM ZAKAZNIK z
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
JOIN KONTAKT k ON k.kontakt_id = z.kontakt_id
JOIN OSOBA o ON o.osoba_id = z.osoba_id
JOIN ADRESA a ON z.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW zamestnanec_view AS
SELECT
    z.zamestnanec_id,
    z.jmeno,
    z.prijmeni,
    z.jmeno || ' ' || z.prijmeni AS cele_jmeno,
    pu.jmeno AS prihlasovaci_jmeno,
    r.nazev AS role_nazev,
    r.role_id,
    n.jmeno AS nadrizeny_jmeno,
    n.prijmeni AS nadrizeny_prijmeni,
    n.jmeno || ' ' || n.prijmeni AS nadrizeny_cele_jmeno,
    pck_utils.zamestnanci_podrizeny(z.zamestnanec_id) podrizeny_podrizenyho
FROM ZAMESTNANEC z
JOIN ROLE r ON r.role_id = z.role_id
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
LEFT JOIN ZAMESTNANEC n ON n.zamestnanec_id = z.nadrizeny_id;
/

CREATE OR REPLACE PROCEDURE uzivatele (
    pocet_radku IN NUMBER,
    radkovani_start IN NUMBER,
    cur_out OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur_out FOR
    SELECT 
        COALESCE(z.zakaznik_id, e.zamestnanec_id) AS uzivatel_id,
        CASE 
            WHEN z.zakaznik_id IS NOT NULL THEN o.jmeno
            ELSE e.jmeno
        END AS jmeno,
        CASE 
            WHEN z.zakaznik_id IS NOT NULL THEN o.prijmeni
            ELSE e.prijmeni
        END AS prijmeni,
        CASE 
            WHEN z.zakaznik_id IS NOT NULL THEN o.jmeno || ' ' || o.prijmeni
            ELSE e.jmeno || ' ' || e.prijmeni
        END AS cele_jmeno,
        pu.jmeno AS prihlasovaci_jmeno,
        pu.heslo AS heslo,
        CASE 
            WHEN z.zakaznik_id IS NOT NULL THEN 'zakaznik'
            ELSE r.nazev
        END AS role,
        COUNT(*) OVER () AS celkovy_pocet_vysledku
    FROM prihlasovaci_udaje pu
    LEFT JOIN zamestnanec e ON pu.prihlasovaci_udaje_id = e.prihlasovaci_udaje_id
    LEFT JOIN zakaznik z ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
    LEFT JOIN osoba o ON z.osoba_id = o.osoba_id
    LEFT JOIN role r ON e.role_id = r.role_id
    OFFSET radkovani_start ROWS FETCH NEXT pocet_radku ROWS ONLY;
END;
/

CREATE VIEW tabulky_view AS
SELECT 
    'Table' AS typ_objektu, 
    table_name AS jmeno_objektu 
FROM user_tables;

CREATE VIEW pohledy_view AS
SELECT 
    'View' AS typ_objektu, 
    view_name AS jmeno_objektu 
FROM user_views;

CREATE VIEW indexy_view AS
SELECT 
    'Index' AS typ_objektu, 
    index_name AS jmeno_objektu 
FROM user_indexes;

CREATE VIEW package_view AS
SELECT 
    'Package' AS typ_objektu, 
    object_name AS jmeno_objektu 
FROM user_objects
WHERE object_type = 'PACKAGE';

CREATE VIEW procedury_view AS
SELECT 
    'Procedure' AS typ_objektu, 
    object_name AS jmeno_objektu 
FROM user_objects
WHERE object_type = 'PROCEDURE';

CREATE VIEW funkce_view AS
SELECT 
    'Function' AS typ_objektu, 
    object_name AS jmeno_objektu 
FROM user_objects
WHERE object_type = 'FUNCTION';

CREATE VIEW triggry_view AS
SELECT 
    'Trigger' AS typ_objektu, 
    trigger_name AS jmeno_objektu 
FROM user_triggers;
