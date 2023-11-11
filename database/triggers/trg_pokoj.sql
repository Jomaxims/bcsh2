CREATE OR REPLACE TRIGGER trigger_pokoj
AFTER INSERT OR UPDATE OR DELETE ON POKOJ
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
        v_after := 'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'POCET_MIST: ' || :NEW.POCET_MIST || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'POCET_MIST: ' || :OLD.POCET_MIST || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'POCET_MIST: ' || :NEW.POCET_MIST || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'POCET_MIST: ' || :OLD.POCET_MIST || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('POKOJ', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
