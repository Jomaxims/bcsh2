CREATE OR REPLACE PACKAGE pck_utils AS
  FUNCTION get_first_image_alphabetically(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
    RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
  
  PROCEDURE DropAllTables;
  PROCEDURE DropAllObjects;
END pck_utils;
/

CREATE OR REPLACE PACKAGE BODY pck_utils AS

  FUNCTION get_first_image_alphabetically(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
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
  END get_first_image_alphabetically;

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
