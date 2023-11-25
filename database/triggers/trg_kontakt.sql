CREATE OR REPLACE TRIGGER trigger_kontakt
AFTER INSERT OR UPDATE OR DELETE ON KONTAKT
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
        v_after := 'KONTAKT_ID: ' || :NEW.KONTAKT_ID || ', EMAIL: ' || :NEW.EMAIL || ', TELEFON: ' || :NEW.TELEFON || ', ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'KONTAKT_ID: ' || :OLD.KONTAKT_ID || ', EMAIL: ' || :OLD.EMAIL || ', TELEFON: ' || :OLD.TELEFON || ', ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := 'KONTAKT_ID: ' || :NEW.KONTAKT_ID || ', EMAIL: ' || :NEW.EMAIL || ', TELEFON: ' || :NEW.TELEFON || ', ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'KONTAKT_ID: ' || :OLD.KONTAKT_ID || ', EMAIL: ' || :OLD.EMAIL || ', TELEFON: ' || :OLD.TELEFON || ', ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := NULL;
    END IF;
    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('KONTAKT', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/