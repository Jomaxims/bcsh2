CREATE OR REPLACE TRIGGER trigger_prihlasovaci_udaje
AFTER INSERT OR UPDATE OR DELETE ON PRIHLASOVACI_UDAJE
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
        v_after := 'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'HESLO: ' || :NEW.HESLO;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'HESLO: ' || :OLD.HESLO;
        v_after := 'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'HESLO: ' || :NEW.HESLO;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'HESLO: ' || :OLD.HESLO;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('PRIHLASOVACI_UDAJE', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
