CREATE OR REPLACE TRIGGER trigger_platba
AFTER INSERT OR UPDATE OR DELETE ON PLATBA
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
        v_after := 'PLATBA_ID: ' || :NEW.PLATBA_ID || ', ' || 
                   'CASTKA: ' || :NEW.CASTKA || ', ' || 
                   'CISLO_UCTU: ' || :NEW.CISLO_UCTU || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'ZAPLACENA: ' || :NEW.ZAPLACENA;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'PLATBA_ID: ' || :OLD.PLATBA_ID || ', ' || 
                    'CASTKA: ' || :OLD.CASTKA || ', ' || 
                    'CISLO_UCTU: ' || :OLD.CISLO_UCTU || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'ZAPLACENA: ' || :OLD.ZAPLACENA;
        v_after := 'PLATBA_ID: ' || :NEW.PLATBA_ID || ', ' || 
                   'CASTKA: ' || :NEW.CASTKA || ', ' || 
                   'CISLO_UCTU: ' || :NEW.CISLO_UCTU || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'ZAPLACENA: ' || :NEW.ZAPLACENA;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'PLATBA_ID: ' || :OLD.PLATBA_ID || ', ' || 
                    'CASTKA: ' || :OLD.CASTKA || ', ' || 
                    'CISLO_UCTU: ' || :OLD.CISLO_UCTU || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'ZAPLACENA: ' || :OLD.ZAPLACENA;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('PLATBA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
