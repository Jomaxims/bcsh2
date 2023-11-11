CREATE OR REPLACE TRIGGER trigger_doprava
AFTER INSERT OR UPDATE OR DELETE ON DOPRAVA
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
        v_after := 'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', NAZEV: ' || :OLD.NAZEV;
        v_after := 'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;
    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('DOPRAVA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
