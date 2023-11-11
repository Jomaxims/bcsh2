CREATE OR REPLACE TRIGGER trigger_zamestnanec
AFTER INSERT OR UPDATE OR DELETE ON ZAMESTNANEC
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
        v_after := 'ZAMESTNANEC_ID: ' || :NEW.ZAMESTNANEC_ID || ', ' || 
                   'ROLE_ID: ' || :NEW.ROLE_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'NADRIZENY_ID: ' || NVL(TO_CHAR(:NEW.NADRIZENY_ID), 'NULL') || ', ' || 
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'PRIJMENI: ' || :NEW.PRIJMENI;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ZAMESTNANEC_ID: ' || :OLD.ZAMESTNANEC_ID || ', ' || 
                    'ROLE_ID: ' || :OLD.ROLE_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'NADRIZENY_ID: ' || NVL(TO_CHAR(:OLD.NADRIZENY_ID), 'NULL') || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'PRIJMENI: ' || :OLD.PRIJMENI;
        v_after := 'ZAMESTNANEC_ID: ' || :NEW.ZAMESTNANEC_ID || ', ' || 
                   'ROLE_ID: ' || :NEW.ROLE_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'NADRIZENY_ID: ' || NVL(TO_CHAR(:NEW.NADRIZENY_ID), 'NULL') || ', ' || 
                   'JMENO: ' || :NEW.JMENO || ', ' || 
                   'PRIJMENI: ' || :NEW.PRIJMENI;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ZAMESTNANEC_ID: ' || :OLD.ZAMESTNANEC_ID || ', ' || 
                    'ROLE_ID: ' || :OLD.ROLE_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'NADRIZENY_ID: ' || NVL(TO_CHAR(:OLD.NADRIZENY_ID), 'NULL') || ', ' || 
                    'JMENO: ' || :OLD.JMENO || ', ' || 
                    'PRIJMENI: ' || :OLD.PRIJMENI;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABEL (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAMESTNANEC', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/
