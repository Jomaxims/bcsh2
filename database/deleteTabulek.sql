CREATE OR REPLACE PROCEDURE DropAllTables IS
BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Failed to drop one or more tables: ' || SQLERRM);
END DropAllTables;




BEGIN
    DropAllTables;
END;
/