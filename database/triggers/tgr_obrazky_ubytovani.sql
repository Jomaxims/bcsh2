CREATE OR REPLACE TRIGGER trigger_obrazky_ubytovani
AFTER INSERT OR UPDATE OR DELETE ON OBRAZKY_UBYTOVANI
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
        v_after := 'OBRAZKY_UBYTOVANI_ID: ' || :NEW.OBRAZKY_UBYTOVANI_ID || ', ' || 
                   'OBRAZEK: [BLOB DATA]' || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV || ', ' || 
                   'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OBRAZKY_UBYTOVANI_ID: ' || :OLD.OBRAZKY_UBYTOVANI_ID || ', ' || 
                    'OBRAZEK: [BLOB DATA]' || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV || ', ' || 
                    'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID;
        v_after := 'OBRAZKY_UBYTOVANI_ID: ' || :NEW.OBRAZKY_UBYTOVANI_ID || ', ' || 
                   'OBRAZEK: [BLOB DATA]' || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV || ', ' || 
                   'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OBRAZKY_UBYTOVANI_ID: ' || :OLD.OBRAZKY_UBYTOVANI_ID || ', ' || 
                    'OBRAZEK: [BLOB DATA]' || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV || ', ' || 
                    'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OBRAZKY_UBYTOVANI', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
