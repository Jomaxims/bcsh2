CREATE OR REPLACE PACKAGE pck_utils AS
  FUNCTION prvni_img_zajezdy(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
    RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
    
  FUNCTION zamestnanci_podrizeny(p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE)
    RETURN VARCHAR2;
    
  FUNCTION calculate_castka(p_pojisteni_id INTEGER, p_termin_id INTEGER,p_pocet_osob INTEGER) 
   RETURN DECIMAL;
   
   PROCEDURE zlevni_zajezdy(rc_out OUT SYS_REFCURSOR);
  
  PROCEDURE DropAllTables;
  PROCEDURE DropAllObjects;
END pck_utils;
/

CREATE OR REPLACE PACKAGE BODY pck_utils AS

FUNCTION prvni_img_zajezdy(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE IS
    v_image_id OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
BEGIN
    SELECT OBRAZKY_UBYTOVANI_ID INTO v_image_id
    FROM (
        SELECT OBRAZKY_UBYTOVANI_ID
        FROM OBRAZKY_UBYTOVANI
        WHERE UBYTOVANI_ID = p_ubytovani_id
        ORDER BY NAZEV
    )
    WHERE ROWNUM = 1;

    RETURN v_image_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END prvni_img_zajezdy;

  
  FUNCTION zamestnanci_podrizeny(p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE)
    RETURN VARCHAR2 IS
    CURSOR podrizeny_cursor IS
      SELECT z.jmeno, z.prijmeni
      FROM zamestnanec z
      WHERE z.zamestnanec_id != p_zamestnanec_id
      START WITH z.nadrizeny_id = p_zamestnanec_id
      CONNECT BY PRIOR z.zamestnanec_id = z.nadrizeny_id
      ORDER SIBLINGS BY z.jmeno;

    v_result VARCHAR2(250) := '';
    v_jmeno zamestnanec.jmeno%TYPE;
    v_prijmeni zamestnanec.prijmeni%TYPE;
  BEGIN
    OPEN podrizeny_cursor;
    LOOP
      FETCH podrizeny_cursor INTO v_jmeno, v_prijmeni;
      EXIT WHEN podrizeny_cursor%NOTFOUND;
      v_result := v_result || v_jmeno || ' ' || v_prijmeni || ', ';
    END LOOP;
    CLOSE podrizeny_cursor;
    RETURN RTRIM(v_result, ', ');
  END zamestnanci_podrizeny;

   FUNCTION calculate_castka(
    p_pojisteni_id INTEGER,
    p_termin_id    INTEGER,
    p_pocet_osob   INTEGER
  ) RETURN DECIMAL IS
    v_cena_za_osobu DECIMAL(10,2);
    v_cena_za_den DECIMAL(10,2);
    v_od DATE;
    v_do DATE;
    v_related_zajezd_id INTEGER;
    v_castka DECIMAL(10,2);
  BEGIN
    SELECT zajezd_id, od, do INTO v_related_zajezd_id, v_od, v_do FROM termin WHERE termin_id = p_termin_id;
    
    SELECT cena_za_osobu INTO v_cena_za_osobu FROM zajezd WHERE zajezd_id = v_related_zajezd_id;
    
    SELECT cena_za_den INTO v_cena_za_den FROM pojisteni WHERE pojisteni_id = p_pojisteni_id;
    
    v_castka := (p_pocet_osob * v_cena_za_osobu) + (p_pocet_osob * v_cena_za_den * (v_do - v_od));
    RETURN v_castka;
  END calculate_castka; 
  
  PROCEDURE zlevni_zajezdy(rc_out OUT SYS_REFCURSOR) IS
   BEGIN
  FOR rec IN (SELECT zajezd_id, cena_za_osobu FROM zajezd WHERE zobrazit = 1) LOOP
    IF rec.cena_za_osobu >= 10000 THEN
      -- Zaokrouhlíme cenu dolů na desetitisíce a vypočítáme slevu
      UPDATE zajezd
      SET cena_za_osobu = TRUNC(rec.cena_za_osobu, -4),
          sleva_procent = ROUND((1 - (TRUNC(rec.cena_za_osobu, -4) / rec.cena_za_osobu)) * 100, 2)
      WHERE zajezd_id = rec.zajezd_id;
    ELSIF rec.cena_za_osobu < 10000 THEN
      UPDATE zajezd
      SET cena_za_osobu = ROUND(rec.cena_za_osobu * 0.7, -4), -- Zaokrouhluje cenu po slevě na celé tisíce dolů
          sleva_procent = 30
      WHERE zajezd_id = rec.zajezd_id;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
  END zlevni_zajezdy;
    
  PROCEDURE DropAllTables IS
  BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Failed to drop and purge one or more tables: ' || SQLERRM);
  END DropAllTables;

  PROCEDURE DropAllObjects IS
  BEGIN
    -- Drop packages
    FOR p IN (SELECT object_name FROM user_objects WHERE object_type = 'PACKAGE') LOOP
      EXECUTE IMMEDIATE 'DROP PACKAGE ' || p.object_name;
    END LOOP;

    -- Drop procedures
    FOR pr IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE') LOOP
      EXECUTE IMMEDIATE 'DROP PROCEDURE ' || pr.object_name;
    END LOOP;

    -- Drop functions
    FOR f IN (SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION') LOOP
      EXECUTE IMMEDIATE 'DROP FUNCTION ' || f.object_name;
    END LOOP;

    -- Drop triggers
    FOR t IN (SELECT trigger_name FROM user_triggers) LOOP
      EXECUTE IMMEDIATE 'DROP TRIGGER ' || t.trigger_name;
    END LOOP;

    -- Drop views
    FOR v IN (SELECT view_name FROM user_views) LOOP
      EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Failed to drop one or more objects: ' || SQLERRM);
  END DropAllObjects;

END pck_utils;
/
