CREATE OR REPLACE TRIGGER trigger_pokoje_terminu
AFTER INSERT OR UPDATE OR DELETE ON POKOJE_TERMINU
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
        v_after := 'CELKOVY_POCET_POKOJU: ' || :NEW.CELKOVY_POCET_POKOJU || ', ' || 
                   'POCET_OBSAZENYCH_POKOJU: ' || :NEW.POCET_OBSAZENYCH_POKOJU || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'CELKOVY_POCET_POKOJU: ' || :OLD.CELKOVY_POCET_POKOJU || ', ' || 
                    'POCET_OBSAZENYCH_POKOJU: ' || :OLD.POCET_OBSAZENYCH_POKOJU || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID;
        v_after := 'CELKOVY_POCET_POKOJU: ' || :NEW.CELKOVY_POCET_POKOJU || ', ' || 
                   'POCET_OBSAZENYCH_POKOJU: ' || :NEW.POCET_OBSAZENYCH_POKOJU || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'CELKOVY_POCET_POKOJU: ' || :OLD.CELKOVY_POCET_POKOJU || ', ' || 
                    'POCET_OBSAZENYCH_POKOJU: ' || :OLD.POCET_OBSAZENYCH_POKOJU || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('POKOJE_TERMINU', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
