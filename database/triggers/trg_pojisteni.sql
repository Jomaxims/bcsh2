CREATE OR REPLACE TRIGGER trigger_pojisteni
AFTER INSERT OR UPDATE OR DELETE ON POJISTENI
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
        v_after := 'POJISTENI_ID: ' || :NEW.POJISTENI_ID || ', ' || 
                   'CENA_ZA_DEN: ' || :NEW.CENA_ZA_DEN || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'POJISTENI_ID: ' || :OLD.POJISTENI_ID || ', ' || 
                    'CENA_ZA_DEN: ' || :OLD.CENA_ZA_DEN || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'POJISTENI_ID: ' || :NEW.POJISTENI_ID || ', ' || 
                   'CENA_ZA_DEN: ' || :NEW.CENA_ZA_DEN || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'POJISTENI_ID: ' || :OLD.POJISTENI_ID || ', ' || 
                    'CENA_ZA_DEN: ' || :OLD.CENA_ZA_DEN || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('POJISTENI', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
