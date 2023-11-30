CREATE
OR REPLACE PACKAGE zajezd_view_pkg AS
  TYPE ref_cursor IS REF CURSOR;

  TYPE
zajezd_rec IS RECORD (
    zajezd_id           INTEGER,
    Nazev_hotelu        VARCHAR2(100),
    Pocet_hvezd         INTEGER,
    popis               VARCHAR2(300),
    Nazev_statu         VARCHAR2(100),
    mesto               VARCHAR2(100),
    psc                 VARCHAR2(10),
    Stat_id             INTEGER,
    Doprava             VARCHAR2(100),
    doprava_id          INTEGER,
    Strava              VARCHAR2(100),
    strava_id           INTEGER,
    Cena_za_osobu_plna  NUMBER,
    Cena_za_osobu_sleva NUMBER
  );

  PROCEDURE open_zajezd_cursor(p_od DATE, p_cursor OUT ref_cursor);
END zajezd_view_pkg;
/

    
    
    CREATE
OR REPLACE PACKAGE BODY zajezd_view_pkg AS
    
      PROCEDURE open_zajezd_cursor(p_od DATE, p_cursor OUT ref_cursor) IS
BEGIN
OPEN p_cursor FOR
SELECT z.zajezd_id,
       u.nazev                                                              AS Nazev_hotelu,
       u.pocet_hvezd                                                        AS Pocet_hvezd,
       SUBSTR(u.popis, 1, 300)                                              AS popis,
       s.nazev                                                              AS Nazev_statu,
       a.mesto,
       a.psc,
       s.stat_id                                                            AS Stat_id,
       d.nazev                                                              AS Doprava,
       d.doprava_id,
       st.nazev                                                             AS Strava,
       st.strava_id,
       z.cena_za_osobu                                                      AS Cena_za_osobu_plna,
       ROUND(z.cena_za_osobu - (z.cena_za_osobu * (z.sleva_procent / 100))) AS Cena_za_osobu_sleva
FROM UBYTOVANI u
         JOIN ADRESA a ON u.adresa_id = a.adresa_id
         JOIN STAT s ON a.stat_id = s.stat_id
         JOIN ZAJEZD z ON u.ubytovani_id = z.ubytovani_id
         JOIN DOPRAVA d ON d.doprava_id = z.doprava_id
         JOIN STRAVA st ON st.strava_id = z.strava_id
         JOIN TERMIN t ON t.zajezd_id = z.zajezd_id
WHERE t.od = p_od
  AND z.zobrazit = 1
ORDER BY t.od
    FETCH FIRST 1 ROW ONLY;

END open_zajezd_cursor;

END zajezd_view_pkg;
/
    