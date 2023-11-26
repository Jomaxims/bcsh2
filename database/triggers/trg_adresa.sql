CREATE OR REPLACE TRIGGER trigger_adresa
AFTER INSERT OR UPDATE OR DELETE ON adresa
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
        v_after := 'ADRESA_ID: ' || :NEW.ADRESA_ID || ', ' || 
                   'ULICE: ' || :NEW.ULICE || ', ' || 
                   'CISLO_POPISNE: ' || :NEW.CISLO_POPISNE || ', ' || 
                   'MESTO: ' || :NEW.MESTO || ', ' || 
                   'PSC: ' || :NEW.PSC || ', ' || 
                   'POZNAMKA: ' || :NEW.POZNAMKA || ', ' || 
                   'STAT_ID: ' || :NEW.STAT_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ADRESA_ID: ' || :OLD.ADRESA_ID || ', ' || 
                    'ULICE: ' || :OLD.ULICE || ', ' || 
                    'CISLO_POPISNE: ' || :OLD.CISLO_POPISNE || ', ' || 
                    'MESTO: ' || :OLD.MESTO || ', ' || 
                    'PSC: ' || :OLD.PSC || ', ' || 
                    'POZNAMKA: ' || :OLD.POZNAMKA || ', ' || 
                    'STAT_ID: ' || :OLD.STAT_ID;
        v_after := 'ADRESA_ID: ' || :NEW.ADRESA_ID || ', ' || 
                   'ULICE: ' || :NEW.ULICE || ', ' || 
                   'CISLO_POPISNE: ' || :NEW.CISLO_POPISNE || ', ' || 
                   'MESTO: ' || :NEW.MESTO || ', ' || 
                   'PSC: ' || :NEW.PSC || ', ' || 
                   'POZNAMKA: ' || :NEW.POZNAMKA || ', ' || 
                   'STAT_ID: ' || :NEW.STAT_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ADRESA_ID: ' || :OLD.ADRESA_ID || ', ' || 
                    'ULICE: ' || :OLD.ULICE || ', ' || 
                    'CISLO_POPISNE: ' || :OLD.CISLO_POPISNE || ', ' || 
                    'MESTO: ' || :OLD.MESTO || ', ' || 
                    'PSC: ' || :OLD.PSC || ', ' || 
                    'POZNAMKA: ' || :OLD.POZNAMKA || ', ' || 
                    'STAT_ID: ' || :OLD.STAT_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ADRESA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
