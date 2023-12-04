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

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OBRAZKY_UBYTOVANI', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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

CREATE OR REPLACE TRIGGER trigger_doprava
AFTER INSERT OR UPDATE OR DELETE ON DOPRAVA
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
        v_after := 'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', NAZEV: ' || :OLD.NAZEV;
        v_after := 'DOPRAVA_ID: ' || :NEW.DOPRAVA_ID || ', NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'DOPRAVA_ID: ' || :OLD.DOPRAVA_ID || ', NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;
    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('DOPRAVA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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
        v_after := 'KONTAKT_ID: ' || :NEW.KONTAKT_ID || ', EMAIL: ' || :NEW.EMAIL || ', TELEFON: ' || :NEW.TELEFON;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'KONTAKT_ID: ' || :OLD.KONTAKT_ID || ', EMAIL: ' || :OLD.EMAIL || ', TELEFON: ' || :OLD.TELEFON;
        v_after := 'KONTAKT_ID: ' || :NEW.KONTAKT_ID || ', EMAIL: ' || :NEW.EMAIL || ', TELEFON: ' || :NEW.TELEFON;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'KONTAKT_ID: ' || :OLD.KONTAKT_ID || ', EMAIL: ' || :OLD.EMAIL || ', TELEFON: ' || :OLD.TELEFON;
        v_after := NULL;
    END IF;
    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('KONTAKT', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_objednavka
AFTER INSERT OR UPDATE OR DELETE ON OBJEDNAVKA
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
        v_after := 'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'POCET_OSOB: ' || :NEW.POCET_OSOB || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POJISTENI_ID: ' || :NEW.POJISTENI_ID || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'POCET_OSOB: ' || :OLD.POCET_OSOB || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POJISTENI_ID: ' || (CASE WHEN :OLD.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:OLD.POJISTENI_ID) END) || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := 'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'POCET_OSOB: ' || :NEW.POCET_OSOB || ', ' || 
                   'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'POJISTENI_ID: ' || (CASE WHEN :NEW.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:NEW.POJISTENI_ID) END) || ', ' || 
                   'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'POCET_OSOB: ' || :OLD.POCET_OSOB || ', ' || 
                    'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'POJISTENI_ID: ' || (CASE WHEN :OLD.POJISTENI_ID IS NULL THEN 'NULL' ELSE TO_CHAR(:OLD.POJISTENI_ID) END) || ', ' || 
                    'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OBJEDNAVKA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trg_osoba_objednavka
AFTER INSERT OR UPDATE OR DELETE ON OSOBA_OBJEDNAVKA
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
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID;
        v_after := 'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('OSOBA_OBJEDNAVKA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_platba
AFTER INSERT OR UPDATE OR DELETE ON PLATBA
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
        v_after := 'PLATBA_ID: ' || :NEW.PLATBA_ID || ', ' || 
                   'CASTKA: ' || :NEW.CASTKA || ', ' || 
                   'CISLO_UCTU: ' || :NEW.CISLO_UCTU || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'ZAPLACENA: ' || :NEW.ZAPLACENA;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'PLATBA_ID: ' || :OLD.PLATBA_ID || ', ' || 
                    'CASTKA: ' || :OLD.CASTKA || ', ' || 
                    'CISLO_UCTU: ' || :OLD.CISLO_UCTU || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'ZAPLACENA: ' || :OLD.ZAPLACENA;
        v_after := 'PLATBA_ID: ' || :NEW.PLATBA_ID || ', ' || 
                   'CASTKA: ' || :NEW.CASTKA || ', ' || 
                   'CISLO_UCTU: ' || :NEW.CISLO_UCTU || ', ' || 
                   'OBJEDNAVKA_ID: ' || :NEW.OBJEDNAVKA_ID || ', ' || 
                   'ZAPLACENA: ' || :NEW.ZAPLACENA;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'PLATBA_ID: ' || :OLD.PLATBA_ID || ', ' || 
                    'CASTKA: ' || :OLD.CASTKA || ', ' || 
                    'CISLO_UCTU: ' || :OLD.CISLO_UCTU || ', ' || 
                    'OBJEDNAVKA_ID: ' || :OLD.OBJEDNAVKA_ID || ', ' || 
                    'ZAPLACENA: ' || :OLD.ZAPLACENA;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('PLATBA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('POJISTENI', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_pokoj
AFTER INSERT OR UPDATE OR DELETE ON POKOJ
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
        v_after := 'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'POCET_MIST: ' || :NEW.POCET_MIST || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'POCET_MIST: ' || :OLD.POCET_MIST || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'POKOJ_ID: ' || :NEW.POKOJ_ID || ', ' || 
                   'POCET_MIST: ' || :NEW.POCET_MIST || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'POKOJ_ID: ' || :OLD.POKOJ_ID || ', ' || 
                    'POCET_MIST: ' || :OLD.POCET_MIST || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('POKOJ', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('PRIHLASOVACI_UDAJE', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_role
AFTER INSERT OR UPDATE OR DELETE ON ROLE
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
        v_after := 'ROLE_ID: ' || :NEW.ROLE_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ROLE_ID: ' || :OLD.ROLE_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'ROLE_ID: ' || :NEW.ROLE_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ROLE_ID: ' || :OLD.ROLE_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ROLE', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_stat
AFTER INSERT OR UPDATE OR DELETE ON STAT
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
        v_after := 'STAT_ID: ' || :NEW.STAT_ID || ', ' || 
                   'ZKRATKA: ' || :NEW.ZKRATKA || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'STAT_ID: ' || :OLD.STAT_ID || ', ' || 
                    'ZKRATKA: ' || :OLD.ZKRATKA || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'STAT_ID: ' || :NEW.STAT_ID || ', ' || 
                   'ZKRATKA: ' || :NEW.ZKRATKA || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'STAT_ID: ' || :OLD.STAT_ID || ', ' || 
                    'ZKRATKA: ' || :OLD.ZKRATKA || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('STAT', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_strava
AFTER INSERT OR UPDATE OR DELETE ON STRAVA
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
        v_after := 'STRAVA_ID: ' || :NEW.STRAVA_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'STRAVA_ID: ' || :OLD.STRAVA_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := 'STRAVA_ID: ' || :NEW.STRAVA_ID || ', ' || 
                   'NAZEV: ' || :NEW.NAZEV;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'STRAVA_ID: ' || :OLD.STRAVA_ID || ', ' || 
                    'NAZEV: ' || :OLD.NAZEV;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('STRAVA', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_termin
AFTER INSERT OR UPDATE OR DELETE ON TERMIN
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
        v_after := 'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'OD: ' || TO_CHAR(:NEW.OD, 'YYYY-MM-DD') || ', ' || 
                   'DO: ' || TO_CHAR(:NEW.DO, 'YYYY-MM-DD') || ', ' || 
                   'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'OD: ' || TO_CHAR(:OLD.OD, 'YYYY-MM-DD') || ', ' || 
                    'DO: ' || TO_CHAR(:OLD.DO, 'YYYY-MM-DD') || ', ' || 
                    'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID;
        v_after := 'TERMIN_ID: ' || :NEW.TERMIN_ID || ', ' || 
                   'OD: ' || TO_CHAR(:NEW.OD, 'YYYY-MM-DD') || ', ' || 
                   'DO: ' || TO_CHAR(:NEW.DO, 'YYYY-MM-DD') || ', ' || 
                   'ZAJEZD_ID: ' || :NEW.ZAJEZD_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'TERMIN_ID: ' || :OLD.TERMIN_ID || ', ' || 
                    'OD: ' || TO_CHAR(:OLD.OD, 'YYYY-MM-DD') || ', ' || 
                    'DO: ' || TO_CHAR(:OLD.DO, 'YYYY-MM-DD') || ', ' || 
                    'ZAJEZD_ID: ' || :OLD.ZAJEZD_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('TERMIN', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAJEZD', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trigger_zakaznik
AFTER INSERT OR UPDATE OR DELETE ON ZAKAZNIK
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
        v_after := 'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :NEW.KONTAKT_ID;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_before := 'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :OLD.KONTAKT_ID;
        v_after := 'ZAKAZNIK_ID: ' || :NEW.ZAKAZNIK_ID || ', ' || 
                   'PRIHLASOVACI_UDAJE_ID: ' || :NEW.PRIHLASOVACI_UDAJE_ID || ', ' || 
                   'OSOBA_ID: ' || :NEW.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :NEW.KONTAKT_ID;
    ELSIF DELETING THEN 
        v_operation := 'DELETE';
        v_before := 'ZAKAZNIK_ID: ' || :OLD.ZAKAZNIK_ID || ', ' || 
                    'PRIHLASOVACI_UDAJE_ID: ' || :OLD.PRIHLASOVACI_UDAJE_ID || ', ' || 
                    'OSOBA_ID: ' || :OLD.OSOBA_ID || ', ' ||
                   'KONTAKT_ID: ' || :OLD.KONTAKT_ID;
        v_after := NULL;
    END IF;

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAKAZNIK', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

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

    INSERT INTO LOG_TABLE (TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO)
    VALUES ('ZAMESTNANEC', v_operation, SYSTIMESTAMP, v_user, v_before, v_after);
END;
/

CREATE OR REPLACE TRIGGER trg_after_insert_objednavka
AFTER INSERT ON objednavka
FOR EACH ROW
DECLARE
    v_celkovy_pocet POKOJE_TERMINU.celkovy_pocet_pokoju%TYPE;
    v_pocet_obsazenych POKOJE_TERMINU.pocet_obsazenych_pokoju%TYPE;
BEGIN
    SELECT celkovy_pocet_pokoju, pocet_obsazenych_pokoju
    INTO v_celkovy_pocet, v_pocet_obsazenych
    FROM POKOJE_TERMINU
    WHERE pokoj_id = :NEW.pokoj_id
    AND termin_id = :NEW.termin_id;

    IF v_pocet_obsazenych < v_celkovy_pocet THEN
        UPDATE POKOJE_TERMINU
        SET pocet_obsazenych_pokoju = v_pocet_obsazenych + 1
        WHERE pokoj_id = :NEW.pokoj_id
        AND termin_id = :NEW.termin_id;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Žádné volné místo pro pokoj_id a termin_id.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Žádné data pro pokoj_id a termin_id nalezeno POKOJE_TERMINU.');
END;
/

CREATE OR REPLACE TRIGGER trg_after_delete_objednavka
AFTER DELETE ON objednavka
FOR EACH ROW
DECLARE
    v_celkovy_pocet POKOJE_TERMINU.celkovy_pocet_pokoju%TYPE;
    v_pocet_obsazenych POKOJE_TERMINU.pocet_obsazenych_pokoju%TYPE;
BEGIN
    SELECT pocet_obsazenych_pokoju INTO v_pocet_obsazenych
    FROM POKOJE_TERMINU
    WHERE pokoj_id = :OLD.pokoj_id
    AND termin_id = :OLD.termin_id;

    IF v_pocet_obsazenych > 0 THEN
        UPDATE POKOJE_TERMINU
        SET pocet_obsazenych_pokoju = v_pocet_obsazenych - 1
        WHERE pokoj_id = :OLD.pokoj_id
        AND termin_id = :OLD.termin_id;
    END IF;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Pro zadané pokoj_id a termin_id bylo vráceno více řádků.');
    WHEN NO_DATA_FOUND THEN
        NULL; 
END;
/

CREATE OR REPLACE TRIGGER trg_update_pocet_osob
AFTER INSERT ON osoba_objednavka
FOR EACH ROW
BEGIN
    UPDATE objednavka
    SET pocet_osob = pocet_osob + 1
    WHERE objednavka_id = :NEW.objednavka_id;
END;
/


CREATE OR REPLACE TRIGGER trg_update_pocet_osob_del
AFTER DELETE ON osoba_objednavka
FOR EACH ROW
BEGIN
    UPDATE objednavka
    SET pocet_osob = pocet_osob - 1 
    WHERE objednavka_id = :OLD.objednavka_id;
END;
/



CREATE OR REPLACE TRIGGER update_castka_after_pocet_osob_change
AFTER UPDATE OF pocet_osob, pojisteni_id ON objednavka
FOR EACH ROW
DECLARE
  v_castka DECIMAL(10,2);
BEGIN
  v_castka := pck_utils.calculate_castka(:NEW.pojisteni_id, :NEW.termin_id, :NEW.pocet_osob);
  
  UPDATE platba
  SET castka = v_castka
  WHERE objednavka_id = :NEW.objednavka_id;
END;
/

CREATE OR REPLACE TRIGGER trg_check_pokoj_id
BEFORE INSERT ON objednavka
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pokoje_terminu
    WHERE pokoj_id = :NEW.pokoj_id AND termin_id = :NEW.termin_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Pokoj_id se neshoduje.');
    END IF;
END;
/
