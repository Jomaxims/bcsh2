CREATE OR REPLACE TRIGGER trigger_ubytovani
AFTER INSERT OR UPDATE OR DELETE ON UBYTOVANI
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
        v_after := 'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV || ', ' || 
                   'POPIS: ' || :NEW.POPIS || ', ' || 
                   'ADRESA_ID: ' || :NEW.ADRESA_ID || ', ' || 
                   'POCET_HVEZD: ' || :NEW.POCET_HVEZD;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV || ', ' || 
                    'POPIS: ' || :OLD.POPIS || ', ' || 
                    'ADRESA_ID: ' || :OLD.ADRESA_ID || ', ' || 
                    'POCET_HVEZD: ' || :OLD.POCET_HVEZD;
        v_after := 'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV || ', ' || 
                   'POPIS: ' || :NEW.POPIS || ', ' || 
                   'ADRESA_ID: ' || :NEW.ADRESA_ID || ', ' || 
                   'POCET_HVEZD: ' || :NEW.POCET_HVEZD;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV || ', ' || 
                    'POPIS: ' || :OLD.POPIS || ', ' || 
                    'ADRESA_ID: ' || :OLD.ADRESA_ID || ', ' || 
                    'POCET_HVEZD: ' || :OLD.POCET_HVEZD;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('UBYTOVANI', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
