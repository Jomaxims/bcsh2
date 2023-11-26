CREATE OR REPLACE VIEW zajezd_view AS
SELECT
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
    z.zajezd_id,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa,
    get_first_image_alphabetically(u.ubytovani_id) AS obrazek
FROM UBYTOVANI u
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id
JOIN ZAJEZD z ON u.ubytovani_id = z.ubytovani_id
JOIN DOPRAVA d ON d.doprava_id = z.doprava_id
JOIN STRAVA st ON st.strava_id = z.strava_id
LEFT JOIN OBRAZKY_UBYTOVANI ou ON ou.ubytovani_id = u.ubytovani_id
WHERE z.zobrazit = 1;

CREATE OR REPLACE VIEW logy_view AS
SELECT
    tabulka,
    operace,
    cas_zmeny,
    uzivatel,
    pred,
    po
FROM LOG_TABEL;

CREATE OR REPLACE VIEW stat_view AS
SELECT
    s.zkratka,
    s.nazev
FROM STAT s
JOIN ADRESA a ON a.stat_id = s.stat_id
JOIN UBYTOVANI u ON u.adresa_id = a.adresa_id;

CREATE OR REPLACE VIEW ubytovani_view AS
SELECT
    u.nazev,
    u.pocet_hvezd,
    u.popis,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev as Nazev_statu,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa
    
FROM UBYTOVANI u
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW objednavka_view AS
SELECT
    os.jmeno,
    os.prijmeni,
    os.jmeno || ' ' || os.prijmeni AS cele_jmeno,
    u.nazev as Nazev_ubytovani,
    t.od,
    t.do,
    p.nazev as Nazev_pokoje,
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
    u.nazev as Nazev_ubytovani,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev as Nazev_statu,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa,
    z.cena_za_osobu,
    z.sleva_procent,
    d.nazev as Nazev_dopravy,
    st.nazev as Nazev_strava,
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
    s.nazev,
    a.ulice || ', ' || a.cislo_popisne || ', ' || a.mesto || ', ' || a.psc || ', ' || s.nazev AS cela_adresa 
    
FROM ZAKAZNIK z
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
JOIN KONTAKT k ON k.kontakt_id = z.kontakt_id
JOIN OSOBA o ON o.osoba_id = z.osoba_id
JOIN ADRESA a ON z.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW zamestnanec_view AS
SELECT
    z.jmeno AS zamestnanec_jmeno,
    z.prijmeni AS zamestnanec_prijmeni,
    z.jmeno || ' ' || z.prijmeni AS zamestnanec_cele_jmeno,
    pu.jmeno AS prihlasovaci_jmeno,
    r.nazev AS role_nazev,
    r.role_id,
    n.jmeno AS nadrizeny_jmeno,
    n.prijmeni AS nadrizeny_prijmeni,
    n.jmeno || ' ' || n.prijmeni AS nadrizeny_cele_jmeno
    
FROM ZAMESTNANEC z
JOIN ROLE r ON r.role_id = z.role_id
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
LEFT JOIN ZAMESTNANEC n ON n.zamestnanec_id = z.nadrizeny_id
WHERE z.prihlasovaci_udaje_id IS NOT NULL;
