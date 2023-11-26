CREATE OR REPLACE TRIGGER trigger_termin
AFTER INSERT OR UPDATE OR DELETE ON TERMIN
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
        v_after := 'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'OD: ' || TO_CHAR(:NEW.OD, 'YYYY-MM-DD') || ', ' || 
                   'DO: ' || TO_CHAR(:NEW.DO, 'YYYY-MM-DD') || ', ' || 
                   'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'OD: ' || TO_CHAR(:OLD.OD, 'YYYY-MM-DD') || ', ' || 
                    'DO: ' || TO_CHAR(:OLD.DO, 'YYYY-MM-DD') || ', ' || 
                    'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID;
        v_after := 'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'OD: ' || TO_CHAR(:NEW.OD, 'YYYY-MM-DD') || ', ' || 
                   'DO: ' || TO_CHAR(:NEW.DO, 'YYYY-MM-DD') || ', ' || 
                   'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'OD: ' || TO_CHAR(:OLD.OD, 'YYYY-MM-DD') || ', ' || 
                    'DO: ' || TO_CHAR(:OLD.DO, 'YYYY-MM-DD') || ', ' || 
                    'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('TERMIN', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
