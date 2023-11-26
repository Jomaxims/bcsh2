CREATE OR REPLACE TRIGGER trigger_objednavka
AFTER INSERT OR UPDATE OR DELETE ON OBJEDNAVKA
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
        v_after := 'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'POCET_OSOB: ' || :NEW.POCET_OSOB || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POJISTENI_ID: ' || :NEW.POJISTENI_ID || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'POCET_OSOB: ' || :OLD.POCET_OSOB || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POJISTENI_ID: ' || (CASE WHEN :OLD.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:OLD.POJISTENI_ID) END) || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := 'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'POCET_OSOB: ' || :NEW.POCET_OSOB || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POJISTENI_ID: ' || (CASE WHEN :NEW.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:NEW.POJISTENI_ID) END) || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'POCET_OSOB: ' || :OLD.POCET_OSOB || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POJISTENI_ID: ' || (CASE WHEN :OLD.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:OLD.POJISTENI_ID) END) || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OBJEDNAVKA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
