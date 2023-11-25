CREATE OR REPLACE VIEW zajezd_view AS
SELECT
     u.nazev AS Nazev_hotelu,
     u.pocet_hvezd AS Pocet_hvezd,
     SUBSTR(u.popis, 1, 300) as popis,
     s.nazev,  
     a.mesto,
     s.stat_id as Stat_id,
     d.nazev as Doprava,
     d.doprava_id,
     st.nazev as Strava,
     st.strava_id,
     ROUND(z.cena_za_osobu) AS Cena_za_osobu_plna,
     ROUND(z.cena_za_osobu - (z.cena_za_osobu*(z.sleva_procent/100))) AS Cena_za_osobu_sleva,
     z.zajezd_id,
     ou.obrazky_ubytovani_id
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
  



select * from zajezd_view;

select * from logy_view;