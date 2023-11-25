CREATE OR REPLACE PROCEDURE DropAllTables IS
BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Failed to drop one or more tables: ' || SQLERRM);
END DropAllTables;


CREATE OR REPLACE PROCEDURE DropAllObjects IS
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
/

-- To execute the procedure
BEGIN
  DropAllObjects;
END;
/


BEGIN
    DropAllTables;
END;
/