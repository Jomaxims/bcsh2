CREATE OR REPLACE TRIGGER trigger_zakaznik
AFTER INSERT OR UPDATE OR DELETE ON ZAKAZNIK
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
        v_after := 'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :NEW.KONTAKT_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :OLD.KONTAKT_ID;
        v_after := 'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :NEW.KONTAKT_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :OLD.KONTAKT_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAKAZNIK', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
