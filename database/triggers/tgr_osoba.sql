CREATE OR REPLACE TRIGGER trigger_osoba
AFTER INSERT OR UPDATE OR DELETE ON OSOBA
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
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'PRIJMENI: ' || :NEW.PRIJMENI || ', ' || 
                   'DATUM_NAROZENI: ' || :NEW.DATUM_NAROZENI;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'PRIJMENI: ' || :OLD.PRIJMENI || ', ' || 
                    'DATUM_NAROZENI: ' || :OLD.DATUM_NAROZENI;
        v_after := 'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' || 
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'PRIJMENI: ' || :NEW.PRIJMENI || ', ' || 
                   'DATUM_NAROZENI: ' || :NEW.DATUM_NAROZENI;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'PRIJMENI: ' || :OLD.PRIJMENI || ', ' || 
                    'DATUM_NAROZENI: ' || :OLD.DATUM_NAROZENI;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OSOBA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
