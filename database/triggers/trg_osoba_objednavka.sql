CREATE OR REPLACE TRIGGER trg_osoba_objednavka
AFTER INSERT OR UPDATE OR DELETE ON OSOBA_OBJEDNAVKA
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
        v_after := 'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID;
        v_after := 'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OSOBA_OBJEDNAVKA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
