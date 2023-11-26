CREATE OR REPLACE PACKAGE pck_utils AS
  FUNCTION prvni_img_zajezdy(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
    RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
    
  FUNCTION zamestnanci_podrizeny(p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE)
    RETURN VARCHAR2;  
  
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
    RETURN v_result;
  END zamestnanci_podrizeny;

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
