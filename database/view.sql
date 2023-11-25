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
    zkratka,
    nazev
FROM STAT;  

CREATE OR REPLACE VIEW ubytovani_view AS
SELECT
    u.nazev,
    u.pocet_hvezd,
    u.popis,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    a.stat_id
FROM UBYTOVANI u
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW objednavka_view AS
SELECT
    os.jmeno,
    os.prijmeni,
    u.nazev as Nazev_ubytovani,
    t.od,
    t.do,
    p.nazev as Nazev_pokoje,
    pl.castka,
    pl.zaplacena
    
FROM OBJEDNAVKA o
JOIN ZAKAZNIK z ON o.zakaznik_id = z.zakaznik_id
JOIN OSOBA os ON os.osoba_id = z.osoba_id
JOIN TERMIN t ON t.termin_id = o.termin_id
JOIN ZAJEZD zaj ON zaj.zajezd_id = t.zajezd_id
JOIN UBYTOVANI u ON u.ubytovani_id = zaj.ubytovani_id
JOIN POKOJ p ON p.pokoj_id = o.pokoj_id
JOIN PLATBA pl ON pl.objednavka_id = o.objednavka_id;

CREATE OR REPLACE VIEW zajezd_zamestnanci_view AS
SELECT
    u.nazev as Nazev_ubytovani,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev as Nazev_statu,
    z.cena_za_osobu,
    z.sleva_procent,
    d.nazev as Nazev_dopravy,
    st.nazev as Nazev_strava
    
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
    pu.jmeno as prihlasovaci_jmeno,
    k.email,
    k.telefon,
    a.ulice,
    a.cislo_popisne,
    a.mesto,
    a.psc,
    s.nazev
    
FROM ZAKAZNIK z
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
JOIN KONTAKT k ON k.kontakt_id = z.kontakt_id
JOIN OSOBA o ON o.osoba_id = z.osoba_id
JOIN ADRESA a ON z.adresa_id = a.adresa_id
JOIN STAT s ON a.stat_id = s.stat_id;

CREATE OR REPLACE VIEW zamestnance_view AS
SELECT
    z.jmeno AS zamestnanec_jmeno,
    z.prijmeni AS zamestnanec_prijmeni,
    pu.jmeno AS prihlasovaci_jmeno,
    r.nazev AS role_nazev,
    n.jmeno AS nadrizeny_jmeno,
    n.prijmeni AS nadrizeny_prijmeni
    
FROM ZAMESTNANEC z
JOIN ROLE r ON r.role_id = z.role_id
JOIN PRIHLASOVACI_UDAJE pu ON pu.prihlasovaci_udaje_id = z.prihlasovaci_udaje_id
LEFT JOIN ZAMESTNANEC n ON n.zamestnanec_id = z.nadrizeny_id
WHERE z.prihlasovaci_udaje_id IS NOT NULL;

select * from zajezd_view;

select * from logy_view;

select * from stat_view;

select * from ubytovani_view;

select * from objednavka_view;

select * from zajezd_zamestnanci_view;
