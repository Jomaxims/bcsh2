CREATE OR REPLACE PROCEDURE get_zajezdy_within_dates(
    termin_od IN DATE, 
    termin_do IN DATE,
    zajezdy_out OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN zajezdy_out FOR
    SELECT DISTINCT
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
        t.do AS Termin_do
    FROM
        UBYTOVANI u
        JOIN ADRESA a ON u.adresa_id = a.adresa_id
        JOIN STAT s ON a.stat_id = s.stat_id
        JOIN ZAJEZD z ON u.ubytovani_id = z.ubytovani_id
        JOIN DOPRAVA d ON d.doprava_id = z.doprava_id
        JOIN STRAVA st ON st.strava_id = z.strava_id
        JOIN TERMIN t ON z.zajezd_id = t.zajezd_id
    WHERE
        z.zobrazit = 1
        AND t.od >= termin_od
        AND t.do <= termin_do;
END;