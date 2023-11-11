CREATE OR REPLACE TRIGGER trigger_zajezd
AFTER INSERT OR UPDATE OR DELETE ON ZAJEZD
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
        v_after := 'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID || ', ' || 
                   'POPIS: ' || :NEW.POPIS || ', ' || 
                   'CENA_ZA_OSOBU: ' || :NEW.CENA_ZA_OSOBU || ', ' || 
                   'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', ' || 
                   'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID || ', ' || 
                   'SLEVA_PROCENT: ' || NVL(TO_CHAR(:NEW.SLEVA_PROCENT), 'NULL') || ', ' || 
                   'ZOBRAZIT: ' || :NEW.ZOBRAZIT || ', ' || 
                   'STRAVA_ID: ' || :NEW.STRAVA_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID || ', ' || 
                    'POPIS: ' || :OLD.POPIS || ', ' || 
                    'CENA_ZA_OSOBU: ' || :OLD.CENA_ZA_OSOBU || ', ' || 
                    'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', ' || 
                    'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID || ', ' || 
                    'SLEVA_PROCENT: ' || NVL(TO_CHAR(:OLD.SLEVA_PROCENT), 'NULL') || ', ' || 
                    'ZOBRAZIT: ' || :OLD.ZOBRAZIT || ', ' || 
                    'STRAVA_ID: ' || :OLD.STRAVA_ID;
        v_after := 'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID || ', ' || 
                   'POPIS: ' || :NEW.POPIS || ', ' || 
                   'CENA_ZA_OSOBU: ' || :NEW.CENA_ZA_OSOBU || ', ' || 
                   'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', ' || 
                   'UBYTOVANI_ID: ' || :NEW.UBYTOVANI_ID || ', ' || 
                   'SLEVA_PROCENT: ' || NVL(TO_CHAR(:NEW.SLEVA_PROCENT), 'NULL') || ', ' || 
                   'ZOBRAZIT: ' || :NEW.ZOBRAZIT || ', ' || 
                   'STRAVA_ID: ' || :NEW.STRAVA_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID || ', ' || 
                    'POPIS: ' || :OLD.POPIS || ', ' || 
                    'CENA_ZA_OSOBU: ' || :OLD.CENA_ZA_OSOBU || ', ' || 
                    'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', ' || 
                    'UBYTOVANI_ID: ' || :OLD.UBYTOVANI_ID || ', ' || 
                    'SLEVA_PROCENT: ' || NVL(TO_CHAR(:OLD.SLEVA_PROCENT), 'NULL') || ', ' || 
                    'ZOBRAZIT: ' || :OLD.ZOBRAZIT || ', ' || 
                    'STRAVA_ID: ' || :OLD.STRAVA_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAJEZD', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
