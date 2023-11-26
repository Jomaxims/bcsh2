CREATE OR REPLACE TRIGGER trigger_stat
AFTER INSERT OR UPDATE OR DELETE ON STAT
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_user VARCHAR2(30);
    v_before CLOB;
    v_after CLOB;
BEGIN
    v_user := USER;

    IF INSERTING THEN 
        v_operation := 'INSERT';
        v_before := NULL;
        v_after := 'STAT_ID: ' || :NEW.STAT_ID || ', ' || 
                   'ZKRATKA: ' || :NEW.ZKRATKA || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'STAT_ID: ' || :OLD.STAT_ID || ', ' || 
                    'ZKRATKA: ' || :OLD.ZKRATKA || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'STAT_ID: ' || :NEW.STAT_ID || ', ' || 
                   'ZKRATKA: ' || :NEW.ZKRATKA || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'STAT_ID: ' || :OLD.STAT_ID || ', ' || 
                    'ZKRATKA: ' || :OLD.ZKRATKA || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('STAT', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
