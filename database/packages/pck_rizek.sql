CREATE OR REPLACE PACKAGE pck_security AS
  FUNCTION hash_hesla(str IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE login(
    p_usr_name IN VARCHAR2, 
    p_usr_pwd IN VARCHAR2, 
    p_cursor OUT SYS_REFCURSOR
  );
END pck_security;
/

CREATE OR REPLACE PACKAGE BODY pck_security AS

    FUNCTION hash_hesla(str IN VARCHAR2) RETURN VARCHAR2 IS
        v_checksum VARCHAR2(32);
    BEGIN
        v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW(
            sys.dbms_obfuscation_toolkit.md5(input_string => str) 
        ) ) );
        RETURN v_checksum;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;
    END hash_hesla;

  PROCEDURE login(
    p_usr_name IN VARCHAR2, 
    p_usr_pwd IN VARCHAR2, 
    p_cursor OUT SYS_REFCURSOR
  ) IS
    v_id PRIHLASOVACI_UDAJE.PRIHLASOVACI_UDAJE_ID%TYPE; 
    v_hashed_pwd VARCHAR2(64);
    v_role_id ZAMESTNANEC.ROLE_ID%TYPE;
    v_zamestnanec_id ZAMESTNANEC.ZAMESTNANEC_ID%TYPE;
    v_error_message VARCHAR2(255);
  BEGIN
    v_hashed_pwd := hash_hesla(p_usr_pwd);

    SELECT PRIHLASOVACI_UDAJE_ID INTO v_id
    FROM PRIHLASOVACI_UDAJE
    WHERE JMENO = p_usr_name
    AND HESLO = v_hashed_pwd;

    -- zakaznik
    BEGIN
        SELECT ZAKAZNIK_ID INTO v_id
        FROM ZAKAZNIK
        WHERE PRIHLASOVACI_UDAJE_ID = v_id;

        OPEN p_cursor FOR
        SELECT ZAKAZNIK_ID AS uzivatel_id, 'zakaznik' AS role
        FROM ZAKAZNIK
        WHERE ZAKAZNIK_ID = v_id;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; 
    END;

    -- zaměstnanec
    BEGIN
        SELECT z.ROLE_ID, z.ZAMESTNANEC_ID INTO v_role_id, v_zamestnanec_id
        FROM ZAMESTNANEC z
        WHERE z.PRIHLASOVACI_UDAJE_ID = v_id;

        OPEN p_cursor FOR
        SELECT ZAMESTNANEC_ID AS uzivatel_id, (SELECT r.NAZEV FROM ROLE r WHERE r.ROLE_ID = v_role_id) AS role
        FROM ZAMESTNANEC
        WHERE ZAMESTNANEC_ID = v_zamestnanec_id;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            OPEN p_cursor FOR
            SELECT NULL AS uzivatel_id, 'Nesprávné jméno nebo heslo' AS role
            FROM DUAL;
            RETURN;
    END;
EXCEPTION
        WHEN OTHERS THEN
            v_error_message := 'Neočekávaný error se vyskytl: ' || SQLERRM;
            OPEN p_cursor FOR
            SELECT NULL AS uzivatel_id, v_error_message AS role
            FROM DUAL;
  END login;

END pck_security;
/

CREATE OR REPLACE PACKAGE pck_utils AS
  FUNCTION prvni_img_zajezdy(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
    RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
    
  FUNCTION zamestnanci_podrizeny(p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE)
    RETURN VARCHAR2;
    
  FUNCTION calculate_castka(p_pojisteni_id INTEGER, p_termin_id INTEGER,p_pocet_osob INTEGER) 
   RETURN DECIMAL;
   
   PROCEDURE zlevni_zajezdy(rc_out OUT SYS_REFCURSOR);
  
  PROCEDURE DropAllTables;
  PROCEDURE DropAllObjects;
END pck_utils;
/

CREATE OR REPLACE PACKAGE BODY pck_utils AS

FUNCTION prvni_img_zajezdy(p_ubytovani_id UBYTOVANI.UBYTOVANI_ID%TYPE)
RETURN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE IS
    v_image_id OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE;
BEGIN
    SELECT OBRAZKY_UBYTOVANI_ID INTO v_image_id
    FROM (
        SELECT OBRAZKY_UBYTOVANI_ID
        FROM OBRAZKY_UBYTOVANI
        WHERE UBYTOVANI_ID = p_ubytovani_id
        ORDER BY NAZEV
    )
    WHERE ROWNUM = 1;

    RETURN v_image_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END prvni_img_zajezdy;

  
  FUNCTION zamestnanci_podrizeny(p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE)
    RETURN VARCHAR2 IS
    CURSOR podrizeny_cursor IS
      SELECT z.jmeno, z.prijmeni
      FROM zamestnanec z
      WHERE z.zamestnanec_id != p_zamestnanec_id
      START WITH z.nadrizeny_id = p_zamestnanec_id
      CONNECT BY PRIOR z.zamestnanec_id = z.nadrizeny_id
      ORDER SIBLINGS BY z.jmeno;

    v_result VARCHAR2(250) := '';
    v_jmeno zamestnanec.jmeno%TYPE;
    v_prijmeni zamestnanec.prijmeni%TYPE;
  BEGIN
    OPEN podrizeny_cursor;
    LOOP
      FETCH podrizeny_cursor INTO v_jmeno, v_prijmeni;
      EXIT WHEN podrizeny_cursor%NOTFOUND;
      v_result := v_result || v_jmeno || ' ' || v_prijmeni || ', ';
    END LOOP;
    CLOSE podrizeny_cursor;
    RETURN RTRIM(v_result, ', ');
  END zamestnanci_podrizeny;

   FUNCTION calculate_castka(
    p_pojisteni_id INTEGER,
    p_termin_id    INTEGER,
    p_pocet_osob   INTEGER
  ) RETURN DECIMAL IS
    v_cena_za_osobu DECIMAL(10,2);
    v_cena_za_den DECIMAL(10,2);
    v_od DATE;
    v_do DATE;
    v_related_zajezd_id INTEGER;
    v_castka DECIMAL(10,2);
  BEGIN
    SELECT zajezd_id, od, do INTO v_related_zajezd_id, v_od, v_do FROM termin WHERE termin_id = p_termin_id;
    
    SELECT cena_za_osobu INTO v_cena_za_osobu FROM zajezd WHERE zajezd_id = v_related_zajezd_id;
    
    SELECT cena_za_den INTO v_cena_za_den FROM pojisteni WHERE pojisteni_id = p_pojisteni_id;
    
    v_castka := (p_pocet_osob * v_cena_za_osobu) + (p_pocet_osob * v_cena_za_den * (v_do - v_od));
    RETURN v_castka;
  END calculate_castka; 
  
  PROCEDURE zlevni_zajezdy(rc_out OUT SYS_REFCURSOR) IS
   BEGIN
  FOR rec IN (SELECT zajezd_id, cena_za_osobu FROM zajezd WHERE zobrazit = 1) LOOP
    IF rec.cena_za_osobu >= 10000 THEN
      -- Zaokrouhlíme cenu dolů na desetitisíce a vypočítáme slevu
      UPDATE zajezd
      SET cena_za_osobu = TRUNC(rec.cena_za_osobu, -4),
          sleva_procent = ROUND((1 - (TRUNC(rec.cena_za_osobu, -4) / rec.cena_za_osobu)) * 100, 2)
      WHERE zajezd_id = rec.zajezd_id;
    ELSIF rec.cena_za_osobu < 10000 THEN
      UPDATE zajezd
      SET cena_za_osobu = ROUND(rec.cena_za_osobu * 0.7, -4), -- Zaokrouhluje cenu po slevě na celé tisíce dolů
          sleva_procent = 30
      WHERE zajezd_id = rec.zajezd_id;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
  END zlevni_zajezdy;
    
  PROCEDURE DropAllTables IS
  BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Failed to drop and purge one or more tables: ' || SQLERRM);
  END DropAllTables;

  PROCEDURE DropAllObjects IS
  BEGIN
    -- Drop packages
    FOR p IN (SELECT object_name FROM user_objects WHERE object_type = 'PACKAGE') LOOP
      EXECUTE IMMEDIATE 'DROP PACKAGE ' || p.object_name;
    END LOOP;

    -- Drop procedures
    FOR pr IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE') LOOP
      EXECUTE IMMEDIATE 'DROP PROCEDURE ' || pr.object_name;
    END LOOP;

    -- Drop functions
    FOR f IN (SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION') LOOP
      EXECUTE IMMEDIATE 'DROP FUNCTION ' || f.object_name;
    END LOOP;

    -- Drop triggers
    FOR t IN (SELECT trigger_name FROM user_triggers) LOOP
      EXECUTE IMMEDIATE 'DROP TRIGGER ' || t.trigger_name;
    END LOOP;

    -- Drop views
    FOR v IN (SELECT view_name FROM user_views) LOOP
      EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Failed to drop one or more objects: ' || SQLERRM);
  END DropAllObjects;

END pck_utils;
/


CREATE OR REPLACE PACKAGE pck_adresa AS

    PROCEDURE manage_adresa(
        p_adresa_id     IN OUT ADRESA.ADRESA_ID%type,
        p_psc           IN adresa.psc%TYPE,
        p_stat_id       IN adresa.stat_id%TYPE,
        p_ulice         IN adresa.ulice%TYPE,
        p_mesto         IN adresa.mesto%TYPE,
        p_cislo_popisne IN adresa.cislo_popisne%TYPE,
        p_poznamka      IN adresa.poznamka%TYPE DEFAULT NULL,
        o_result        OUT CLOB
    );

    PROCEDURE delete_adresa(
        p_adresa_id     IN ADRESA.ADRESA_ID%type,
        o_result        OUT CLOB
    );

END pck_adresa;
/

CREATE OR REPLACE PACKAGE BODY pck_adresa AS

    PROCEDURE manage_adresa(
        p_adresa_id     IN OUT ADRESA.ADRESA_ID%type,
        p_psc           IN adresa.psc%TYPE,
        p_stat_id       IN adresa.stat_id%TYPE,
        p_ulice         IN adresa.ulice%TYPE,
        p_mesto         IN adresa.mesto%TYPE,
        p_cislo_popisne IN adresa.cislo_popisne%TYPE,
        p_poznamka      IN adresa.poznamka%TYPE DEFAULT NULL,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_adresa_id IS NULL THEN
            INSERT INTO ADRESA(ULICE, CISLO_POPISNE, MESTO, PSC, POZNAMKA, STAT_ID)
                VALUES(p_ulice, p_cislo_popisne, p_mesto, p_psc, p_poznamka, p_stat_id)
                returning adresa_id into p_adresa_id;
                o_result := '{ "status": "OK", "message": "Adresa byla uspesne vytvorena." }';
        ELSE
             UPDATE ADRESA
                SET ULICE = p_ulice,
                    CISLO_POPISNE = p_cislo_popisne,
                    MESTO = p_mesto,
                    PSC = p_psc,
                    POZNAMKA = p_poznamka,
                    STAT_ID = p_stat_id
                WHERE ADRESA_ID = p_adresa_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa aktualizov�n �sp?�n?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_adresa;

    PROCEDURE delete_adresa(
         p_adresa_id     IN ADRESA.ADRESA_ID%type,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_adresa_id IS NOT NULL THEN 
            DELETE FROM ADRESA WHERE ADRESA_ID =  p_adresa_id;
        
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa smaz�na �sp?�n?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_adresa;

END pck_adresa;
/

CREATE OR REPLACE PACKAGE pck_kontakt AS

    PROCEDURE manage_kontakt(
        p_telefon       IN kontakt.telefon%TYPE,
        p_kontakt_id    IN OUT kontakt.kontakt_id%TYPE,
        p_email         IN kontakt.email%TYPE,
        o_result        OUT CLOB
    );

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result     OUT CLOB
    );

END pck_kontakt;
/

CREATE OR REPLACE PACKAGE BODY pck_kontakt AS

    PROCEDURE manage_kontakt(
        p_telefon       IN kontakt.telefon%TYPE,
        p_kontakt_id    IN OUT kontakt.kontakt_id%TYPE,
        p_email         IN kontakt.email%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NULL THEN
            INSERT INTO kontakt
                 (telefon,
                 email)
            VALUES
                (p_telefon,
                 p_email)
            RETURNING kontakt_id INTO p_kontakt_id;
            o_result := '{ "status": "OK", "message": "Kontakt byl uspesne vytvoren." }';
        ELSE
            UPDATE kontakt
            SET    telefon = p_telefon,
                   email = p_email
            WHERE  kontakt_id = p_kontakt_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID kontakt nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt aktualizován úspěšně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_kontakt;

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NOT NULL THEN 
            DELETE FROM kontakt WHERE kontakt_id = p_kontakt_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt smazán úspěšně." }';
            END IF;
        ELSE
            o_result := '{ "status": "error", "message": "Chyba: Nebylo zadáno žádné ID kontaktu pro smazání." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_kontakt;

END pck_kontakt;
/

CREATE OR REPLACE PACKAGE pck_log AS

    PROCEDURE manage_log(
        p_log_id   IN OUT LOG_TABLE.log_id%TYPE,
        p_tabulka  IN LOG_TABLE.tabulka%TYPE,
        p_operace  IN LOG_TABLE.operace%TYPE,
        p_cas_zmeny IN LOG_TABLE.cas_zmeny%TYPE,
        p_uzivatel  IN LOG_TABLE.uzivatel%TYPE,
        p_pred     IN LOG_TABLE.pred%TYPE,
        p_po       IN LOG_TABLE.po%TYPE,
        o_result   OUT CLOB
    );

    PROCEDURE delete_log(
        p_log_id   IN LOG_TABLE.log_id%TYPE,
        o_result   OUT CLOB
    );

END pck_log;
/

CREATE OR REPLACE PACKAGE BODY pck_log AS

    PROCEDURE manage_log(
        p_log_id   IN OUT LOG_TABLE.log_id%TYPE,
        p_tabulka  IN LOG_TABLE.tabulka%TYPE,
        p_operace  IN LOG_TABLE.operace%TYPE,
        p_cas_zmeny IN LOG_TABLE.cas_zmeny%TYPE,
        p_uzivatel  IN LOG_TABLE.uzivatel%TYPE,
        p_pred     IN LOG_TABLE.pred%TYPE,
        p_po       IN LOG_TABLE.po%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_log_id IS NULL THEN
            INSERT INTO LOG_TABLE (tabulka, operace, cas_zmeny, uzivatel, pred, po)
            VALUES (p_tabulka, p_operace, p_cas_zmeny, p_uzivatel, p_pred, p_po)
            RETURNING log_id INTO p_log_id;
            
            o_result := '{ "status": "OK", "message": "Log zaznam byl uspesne vytvoren." }';
        ELSE
            UPDATE LOG_TABLE
            SET tabulka = p_tabulka,
                operace = p_operace,
                cas_zmeny = p_cas_zmeny,
                uzivatel = p_uzivatel,
                pred = p_pred,
                po = p_po
            WHERE log_id = p_log_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: LOG_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Log zaznam byl uspesne aktualizovan." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_log;

    PROCEDURE delete_log(
        p_log_id   IN LOG_TABLE.log_id%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        DELETE FROM LOG_TABLE WHERE log_id = p_log_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Log nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": Log byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_log;

END pck_log;
/

CREATE OR REPLACE PACKAGE pck_objednavka AS

    PROCEDURE manage_objednavka(
        p_objednavka_id IN OUT OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_pocet_osob IN OBJEDNAVKA.POCET_OSOB%TYPE,
        p_termin_id IN OBJEDNAVKA.TERMIN_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_objednavka(
        p_objednavka_id IN OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

END pck_objednavka;
/

CREATE OR REPLACE PACKAGE BODY pck_objednavka AS

    PROCEDURE manage_objednavka(
        p_objednavka_id IN OUT OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_pocet_osob IN OBJEDNAVKA.POCET_OSOB%TYPE,
        p_termin_id IN OBJEDNAVKA.TERMIN_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_objednavka_id IS NULL THEN
            INSERT INTO OBJEDNAVKA
                (POCET_OSOB, TERMIN_ID, POJISTENI_ID, POKOJ_ID, ZAKAZNIK_ID)
            VALUES
                (p_pocet_osob, p_termin_id, p_pojisteni_id, p_pokoj_id, p_zakaznik_id)
            RETURNING OBJEDNAVKA_ID INTO p_objednavka_id;

            o_result := '{ "status": "OK", "message": "Nová objednávka byla úspěšně vytvořena." }';
        ELSE
            UPDATE OBJEDNAVKA
            SET
                POCET_OSOB = p_pocet_osob,
                TERMIN_ID = p_termin_id,
                POJISTENI_ID = p_pojisteni_id,
                POKOJ_ID = p_pokoj_id,
                ZAKAZNIK_ID = p_zakaznik_id
            WHERE
                OBJEDNAVKA_ID = p_objednavka_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Objednávka s daným ID nebyla nalezena." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Objednávka byla úspěšně aktualizována." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END manage_objednavka;

    PROCEDURE delete_objednavka(
        p_objednavka_id IN OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OBJEDNAVKA WHERE OBJEDNAVKA_ID = p_objednavka_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Objednávka s daným ID nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Objednávka byla úspěšně smazána." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END delete_objednavka;

END pck_objednavka;
/

CREATE OR REPLACE PACKAGE pck_obrazky_ubytovani AS

    PROCEDURE manage_obrazky_ubytovani(
        p_obrazky_ubytovani_id IN OUT obrazky_ubytovani.obrazky_ubytovani_id%TYPE,
        p_obrazek              IN obrazky_ubytovani.obrazek%TYPE,
        p_nazev                IN obrazky_ubytovani.nazev%TYPE,
        p_ubytovani_id         IN obrazky_ubytovani.ubytovani_id%TYPE,
        o_result               OUT CLOB
    );

    PROCEDURE delete_obrazky_ubytovani(
        p_obrazky_ubytovani_id IN obrazky_ubytovani.obrazky_ubytovani_id%TYPE,
        o_result               OUT CLOB
    );

END pck_obrazky_ubytovani;
/

CREATE OR REPLACE PACKAGE BODY pck_obrazky_ubytovani AS

    PROCEDURE manage_obrazky_ubytovani(
        p_obrazky_ubytovani_id IN OUT obrazky_ubytovani.obrazky_ubytovani_id%TYPE,
        p_obrazek              IN obrazky_ubytovani.obrazek%TYPE,
        p_nazev                IN obrazky_ubytovani.nazev%TYPE,
        p_ubytovani_id         IN obrazky_ubytovani.ubytovani_id%TYPE,
        o_result               OUT CLOB
    ) IS
    BEGIN
        IF p_obrazky_ubytovani_id IS NULL THEN
            INSERT INTO obrazky_ubytovani (obrazek, nazev, ubytovani_id)
            VALUES (p_obrazek, p_nazev, p_ubytovani_id)
            RETURNING obrazky_ubytovani_id INTO p_obrazky_ubytovani_id;
            
            o_result := '{ "status": "OK", "message": "Nový obrázek byl úspěšně vytvořen." }';
        ELSE
            UPDATE obrazky_ubytovani
            SET obrazek     = p_obrazek,
                nazev       = p_nazev,
                ubytovani_id = p_ubytovani_id
            WHERE obrazky_ubytovani_id = p_obrazky_ubytovani_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Obrázek s daným ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Obrázek byl úspěšně aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END manage_obrazky_ubytovani;

    PROCEDURE delete_obrazky_ubytovani(
        p_obrazky_ubytovani_id IN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OBRAZKY_UBYTOVANI WHERE OBRAZKY_UBYTOVANI_ID = p_obrazky_ubytovani_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Obrázek s daným ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Obrázek byl úspěšně smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END delete_obrazky_ubytovani;

END pck_obrazky_ubytovani;
/

CREATE OR REPLACE PACKAGE pck_osoba_objednavka AS

    PROCEDURE manage_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

END pck_osoba_objednavka;
/

CREATE OR REPLACE PACKAGE BODY pck_osoba_objednavka AS

    PROCEDURE manage_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        INSERT INTO OSOBA_OBJEDNAVKA (OSOBA_ID, OBJEDNAVKA_ID)
        VALUES (p_osoba_id, p_objednavka_id);

        o_result := '{"status": "OK", "message": "Záznam byl úspěně vytvořen."}';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Chyba při operaci: ' || SQLERRM || '"}';
    END manage_osoba_objednavka;

    PROCEDURE delete_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OSOBA_OBJEDNAVKA WHERE OSOBA_ID = p_osoba_id AND OBJEDNAVKA_ID = p_objednavka_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Záznam nebyl nalezen."}';
        ELSE
            o_result := '{"status": "OK", "message": "Záznam byl úspěně smazán."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Chyba při operaci: ' || SQLERRM || '"}';
    END delete_osoba_objednavka;

END pck_osoba_objednavka;
/

CREATE OR REPLACE PACKAGE pck_osoba AS

    PROCEDURE manage_osoba(
        p_osoba_id      IN OUT osoba.osoba_id%TYPE,
        p_prijmeni      IN osoba.prijmeni%TYPE,
        p_jmeno         IN osoba.jmeno%TYPE,
        p_datum_narozeni IN osoba.datum_narozeni%TYPE,
        o_result        OUT CLOB
    );

    PROCEDURE delete_osoba(
        p_osoba_id  IN osoba.osoba_id%TYPE,
        o_result    OUT CLOB
    );

END pck_osoba;
/

CREATE OR REPLACE PACKAGE BODY pck_osoba AS

    PROCEDURE manage_osoba(
        p_osoba_id      IN OUT osoba.osoba_id%TYPE,
        p_prijmeni      IN osoba.prijmeni%TYPE,
        p_jmeno         IN osoba.jmeno%TYPE,
        p_datum_narozeni IN osoba.datum_narozeni%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_osoba_id IS NULL THEN
            INSERT INTO osoba
                (jmeno,
                 prijmeni,
                 datum_narozeni)
            VALUES
                (p_jmeno,
                 p_prijmeni,
                 p_datum_narozeni)
            RETURNING osoba_id INTO p_osoba_id;
            o_result := '{ "status": "OK", "message": "Osoba byla uspesne vytvorena." }';
        ELSE
            UPDATE osoba
            SET
                jmeno = p_jmeno,
                prijmeni = p_prijmeni,
                datum_narozeni = p_datum_narozeni
            WHERE
                osoba_id = p_osoba_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Osoba aktualizována úspěšně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_osoba;

    PROCEDURE delete_osoba(
        p_osoba_id  IN osoba.osoba_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        IF p_osoba_id IS NOT NULL THEN
            DELETE FROM osoba WHERE osoba_id = p_osoba_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Osoba smazána úspěšně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_osoba;

END pck_osoba;
/

CREATE OR REPLACE PACKAGE pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id        IN OUT platba.platba_id%TYPE,
        p_castka           IN platba.castka%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        p_objednavka_id    IN platba.objednavka_id%TYPE,
        p_zaplacena        IN platba.zaplacena%TYPE,
        o_result           OUT CLOB
    );
    
    PROCEDURE zaplat_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        o_result           OUT CLOB
    );

    PROCEDURE delete_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        o_result           OUT CLOB
    );

END pck_platba;
/

CREATE OR REPLACE PACKAGE BODY pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id        IN OUT platba.platba_id%TYPE,
        p_castka           IN platba.castka%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        p_objednavka_id    IN platba.objednavka_id%TYPE,
        p_zaplacena        IN platba.zaplacena%TYPE,
        o_result           OUT CLOB
    ) IS
    BEGIN
        IF p_platba_id IS NULL THEN
            INSERT INTO platba
                (castka, cislo_uctu, objednavka_id, zaplacena)
            VALUES
                (p_castka, p_cislo_uctu, p_objednavka_id, p_zaplacena)
            RETURNING platba_id INTO p_platba_id;

            o_result := '{"status": "OK", "message": "Nová platba byla úspěně vytvořena."}';
        ELSE
            UPDATE platba
            SET
                castka = p_castka,
                cislo_uctu = p_cislo_uctu,
                objednavka_id = p_objednavka_id,
                zaplacena = p_zaplacena
            WHERE
                platba_id = p_platba_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
            ELSE
                o_result := '{"status": "OK", "message": "Platba byla úspěně aktualizována."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_platba;
    
    PROCEDURE zaplat_platba(
    p_platba_id        IN platba.platba_id%TYPE,
    p_cislo_uctu       IN platba.cislo_uctu%TYPE,
    o_result           OUT CLOB
    ) IS
    BEGIN
    UPDATE platba
    SET
        cislo_uctu = p_cislo_uctu,
        zaplacena = 1
    WHERE
        platba_id = p_platba_id;

    IF SQL%ROWCOUNT = 0 THEN
        o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
    ELSE
        o_result := '{"status": "OK", "message": "Platba byla úspěšně zaplacena."}';
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END zaplat_platba;


    PROCEDURE delete_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        o_result           OUT CLOB
    ) IS
    BEGIN
        DELETE FROM platba WHERE platba_id = p_platba_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
        ELSE
            o_result := '{"status": "OK", "message": "Platba byla úspěně smazána."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_platba;

END pck_platba;
/

CREATE OR REPLACE PACKAGE pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT pojisteni.pojisteni_id%TYPE,
        p_cena_za_den IN pojisteni.cena_za_den%TYPE,
        p_nazev       IN pojisteni.nazev%TYPE,
        o_result      OUT CLOB
    );

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN pojisteni.pojisteni_id%TYPE,
        o_result      OUT CLOB
    );

END pck_pojisteni;
/

CREATE OR REPLACE PACKAGE BODY pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT pojisteni.pojisteni_id%TYPE,
        p_cena_za_den IN pojisteni.cena_za_den%TYPE,
        p_nazev       IN pojisteni.nazev%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        IF p_pojisteni_id IS NULL THEN
            INSERT INTO pojisteni
                (cena_za_den, nazev)
            VALUES
                (p_cena_za_den, p_nazev)
            RETURNING pojisteni_id INTO p_pojisteni_id;

            o_result := '{"status": "OK", "message": "Nové pojistění bylo úspěně vytvořeno."}';
        ELSE
            UPDATE pojisteni
            SET
                cena_za_den = p_cena_za_den,
                nazev = p_nazev
            WHERE
                pojisteni_id = p_pojisteni_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Pojistění s daným ID nebylo nalezeno."}';
            ELSE
                o_result := '{"status": "OK", "message": "Pojistění bylo úspěně aktualizováno."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_pojisteni;

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN pojisteni.pojisteni_id%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        DELETE FROM pojisteni WHERE pojisteni_id = p_pojisteni_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Pojistění s daným ID nebylo nalezeno."}';
        ELSE
            o_result := '{"status": "OK", "message": "Pojistění bylo úspěně smazáno."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_pojisteni;

END pck_pojisteni;
/

CREATE OR REPLACE PACKAGE pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id   IN OUT pokoj.pokoj_id%TYPE,
        p_pocet_mist IN pokoj.pocet_mist%TYPE,
        p_nazev      IN pokoj.nazev%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_pokoj(
        p_pokoj_id   IN pokoj.pokoj_id%TYPE,
        o_result     OUT CLOB
    );

END pck_pokoj;
/

CREATE OR REPLACE PACKAGE BODY pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id   IN OUT pokoj.pokoj_id%TYPE,
        p_pocet_mist IN pokoj.pocet_mist%TYPE,
        p_nazev      IN pokoj.nazev%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_pokoj_id IS NULL THEN
            INSERT INTO pokoj (pocet_mist, nazev)
            VALUES (p_pocet_mist, p_nazev)
            RETURNING pokoj_id INTO p_pokoj_id;
            o_result := '{"status": "OK", "message": "Nový pokoj byl úspěně vytvořen."}';
        ELSE
            UPDATE pokoj
            SET pocet_mist = p_pocet_mist,
                nazev = p_nazev
            WHERE pokoj_id = p_pokoj_id;
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Pokoj s daným ID nebyl nalezen."}';
            ELSE
                o_result := '{"status": "OK", "message": "Pokoj byl úspěně aktualizován."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_pokoj;

    PROCEDURE delete_pokoj(
        p_pokoj_id   IN pokoj.pokoj_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        DELETE FROM pokoj WHERE pokoj_id = p_pokoj_id;
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Pokoj s daným ID nebyl nalezen."}';
        ELSE
            o_result := '{"status": "OK", "message": "Pokoj byl úspěně smazán."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_pokoj;

END pck_pokoj;
/

CREATE OR REPLACE PACKAGE pck_pokoje_terminu AS

    PROCEDURE manage_pokoje_terminu(
        p_termin_id IN OUT POKOJE_TERMINU.TERMIN_ID%TYPE,
        p_celkovy_pocet_pokoju IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoju IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
        p_pokoj_id IN OUT POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_pokoje_terminu(
        p_termin_id IN POKOJE_TERMINU.TERMIN_ID%TYPE,
        p_pokoj_id IN POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    );
    
    PROCEDURE delete_pokoje_terminu(
        p_termin_id IN pokoje_terminu.termin_id%TYPE,
        o_result OUT CLOB
    );

END pck_pokoje_terminu;
/

CREATE OR REPLACE PACKAGE BODY pck_pokoje_terminu AS

    PROCEDURE manage_pokoje_terminu(
        p_termin_id IN OUT POKOJE_TERMINU.TERMIN_ID%TYPE,
        p_celkovy_pocet_pokoju IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoju IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
        p_pokoj_id IN OUT POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    ) IS
        v_exists NUMBER;
    BEGIN
        SELECT COUNT(*)
    INTO v_exists
    FROM POKOJE_TERMINU
    WHERE TERMIN_ID = p_termin_id AND POKOJ_ID = p_pokoj_id;

    IF v_exists > 0 THEN
        UPDATE POKOJE_TERMINU
        SET CELKOVY_POCET_POKOJU = p_celkovy_pocet_pokoju,
            POCET_OBSAZENYCH_POKOJU = p_pocet_obsazenych_pokoju
        WHERE TERMIN_ID = p_termin_id AND POKOJ_ID = p_pokoj_id;

        o_result := '{ "status": "OK", "message": "Záznam byl úspěně aktualizován." }';
    ELSE
        INSERT INTO POKOJE_TERMINU (CELKOVY_POCET_POKOJU, POCET_OBSAZENYCH_POKOJU, POKOJ_ID, TERMIN_ID)
        VALUES (p_celkovy_pocet_pokoju, p_pocet_obsazenych_pokoju, p_pokoj_id, p_termin_id)
        RETURNING TERMIN_ID, POKOJ_ID INTO p_termin_id, p_pokoj_id;

        o_result := '{ "status": "OK", "message": "Nový záznam byl úspěně vytvořen." }';
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || REPLACE(SQLERRM, '"', '\"') || '" }';
END manage_pokoje_terminu;

    PROCEDURE delete_pokoje_terminu(
        p_termin_id IN POKOJE_TERMINU.TERMIN_ID%TYPE,
        p_pokoj_id IN POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM POKOJE_TERMINU WHERE TERMIN_ID = p_termin_id AND POKOJ_ID = p_pokoj_id;
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Záznam s daným ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam byl úspěně smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || REPLACE(SQLERRM, '"', '\"') || '" }';
    END delete_pokoje_terminu;
    
    PROCEDURE delete_pokoje_terminu(
        p_termin_id IN pokoje_terminu.termin_id%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM pokoje_terminu WHERE termin_id = p_termin_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Záznam s daným ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam byl úspěně smazán." }';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || REPLACE(SQLERRM, '"', '\"') || '" }';
    END delete_pokoje_terminu;

END pck_pokoje_terminu;
/

CREATE OR REPLACE PACKAGE pck_prihlasovaci_udaje AS

    PROCEDURE manage_prihlasovaci_udaje(
    p_prihlasovaci_udaje_id IN OUT prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
    p_jmeno    IN prihlasovaci_udaje.jmeno%TYPE,
    p_heslo    IN prihlasovaci_udaje.heslo%TYPE,
    o_result   OUT CLOB
    );

    PROCEDURE delete_prihlasovaci_udaje(
        p_prihlasovaci_udaje_id IN prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
        o_result   OUT CLOB
    );

END pck_prihlasovaci_udaje;
/

CREATE OR REPLACE PACKAGE BODY pck_prihlasovaci_udaje AS

     PROCEDURE manage_prihlasovaci_udaje(
        p_prihlasovaci_udaje_id IN OUT prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_jmeno    IN prihlasovaci_udaje.jmeno%TYPE,
        p_heslo    IN prihlasovaci_udaje.heslo%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_prihlasovaci_udaje_id IS NULL THEN
        INSERT INTO prihlasovaci_udaje
              (jmeno, heslo)
        VALUES (p_jmeno, pck_security.hash_hesla(p_heslo))
        RETURNING prihlasovaci_udaje_id INTO p_prihlasovaci_udaje_id;

        o_result := '{ "status": "OK", "message": "Údaje byly úspěšně vytvořeny." }';
    ELSE
        IF p_jmeno IS NULL AND p_heslo IS NULL THEN
            o_result := '{ "status": "OK", "message": "Nebyly zadány údaje k vyplnění." }';
        ELSE
            IF  p_jmeno IS NOT NULL AND p_heslo IS NULL THEN
                UPDATE prihlasovaci_udaje
                SET jmeno = p_jmeno
                WHERE prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;
            END IF;

            IF p_jmeno IS NULL AND p_heslo IS NOT NULL THEN
                UPDATE prihlasovaci_udaje
                SET heslo = pck_security.hash_hesla(p_heslo)
                WHERE prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;
            END IF;
                
            IF p_jmeno IS NOT NULL AND p_heslo IS NOT NULL THEN
                UPDATE prihlasovaci_udaje
                SET jmeno = p_jmeno,
                    heslo = pck_security.hash_hesla(p_heslo)
                WHERE prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;
            END IF;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje aktualizovány úspěšně." }';
            END IF;
        END IF;
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
        o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_prihlasovaci_udaje;

    PROCEDURE delete_prihlasovaci_udaje(
       p_prihlasovaci_udaje_id IN prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_prihlasovaci_udaje_id IS NOT NULL THEN
            DELETE FROM prihlasovaci_udaje WHERE prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje smazány úspěšně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_prihlasovaci_udaje;

END pck_prihlasovaci_udaje;
/

CREATE OR REPLACE PACKAGE pck_role AS

    PROCEDURE manage_role(
        p_role_id IN OUT role.role_id%TYPE,
        p_nazev   IN role.nazev%TYPE,
        o_result  OUT CLOB
    );

    PROCEDURE delete_role(
        p_role_id IN role.role_id%TYPE,
        o_result  OUT CLOB
    );

END pck_role;
/

CREATE OR REPLACE PACKAGE BODY pck_role AS

    PROCEDURE manage_role(
        p_role_id IN OUT role.role_id%TYPE,
        p_nazev   IN role.nazev%TYPE,
        o_result  OUT CLOB
    ) IS
    BEGIN
        IF p_role_id IS NULL THEN
            INSERT INTO role (nazev)
            VALUES (p_nazev)
            RETURNING role_id INTO p_role_id;
            
            o_result := '{ "status": "OK", "message": "Role byla uspesne vytvorena." }';
        ELSE
            UPDATE role
            SET nazev = p_nazev
            WHERE role_id = p_role_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ROLE ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Role byla aktualizovana uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_role;

    PROCEDURE delete_role(
        p_role_id IN role.role_id%TYPE,
        o_result  OUT CLOB
    ) IS
    BEGIN
        DELETE FROM role WHERE role_id = p_role_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Role nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Role byla smazana." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_role;

END pck_role;
/

CREATE OR REPLACE PACKAGE pck_stat AS

    PROCEDURE manage_stat(
        p_stat_id      IN  OUT stat.stat_id %TYPE,
        p_zkratka       stat.zkratka %TYPE,
        p_nazev         stat.nazev %TYPE,
        o_result        OUT VARCHAR2
    );
    
    PROCEDURE delete_stat(
        p_stat_id   IN stat.stat_id %TYPE,
        o_result    OUT VARCHAR2
    );

END pck_stat;
/

CREATE OR REPLACE PACKAGE BODY pck_stat AS

    PROCEDURE manage_stat(
        p_stat_id      IN OUT stat.stat_id%TYPE,
        p_zkratka       stat.zkratka%TYPE,
        p_nazev         stat.nazev%TYPE,
        o_result        OUT VARCHAR2
    ) IS
    BEGIN
        IF p_stat_id IS NULL THEN
            INSERT INTO STAT(ZKRATKA, NAZEV)
            VALUES(p_zkratka, p_nazev)
            RETURNING stat_id INTO p_stat_id;
            o_result := '{ "status": "OK", "message": "Stát přidán úspěně." }';
        ELSE
            UPDATE STAT
            SET ZKRATKA = p_zkratka, NAZEV = p_nazev
            WHERE STAT_ID = p_stat_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Stát aktualizován úspěně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_stat;

    PROCEDURE delete_stat(
        p_stat_id   IN stat.stat_id %TYPE,
        o_result    OUT VARCHAR2
    ) IS
    BEGIN
        IF p_stat_id IS NOT NULL THEN
            DELETE FROM STAT WHERE STAT_ID = p_stat_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Stát smazán úspěně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_stat;

END pck_stat;
/

CREATE OR REPLACE PACKAGE pck_strava AS

    PROCEDURE manage_strava(
        p_strava_id IN OUT strava.strava_id%TYPE,
        p_nazev     IN strava.nazev%TYPE,
        o_result    OUT CLOB
    );

    PROCEDURE delete_strava(
        p_strava_id IN strava.strava_id%TYPE,
        o_result    OUT CLOB
    );

END pck_strava;
/

CREATE OR REPLACE PACKAGE BODY pck_strava AS

    PROCEDURE manage_strava(
        p_strava_id IN OUT strava.strava_id%TYPE,
        p_nazev     IN strava.nazev%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        IF p_strava_id IS NULL THEN
            INSERT INTO strava (nazev)
            VALUES (p_nazev)
            RETURNING strava_id INTO p_strava_id;
            
            o_result := '{ "status": "OK", "message": "Strava byla uspesne vytvorena." }';
        ELSE
            UPDATE strava
            SET nazev = p_nazev
            WHERE strava_id = p_strava_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Strava ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Strava aktualizovana �sp?�n?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_strava;

    PROCEDURE delete_strava(
        p_strava_id IN strava.strava_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        DELETE FROM strava WHERE strava_id = p_strava_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Strava nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Strava byla smazana." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_strava;

END pck_strava;
/

CREATE OR REPLACE PACKAGE pck_termin AS

    PROCEDURE manage_termin(
        p_termin_id IN OUT termin.termin_id%TYPE,
        p_od         IN termin.od%TYPE,
        p_do         IN termin.do%TYPE,
        p_zajezd_id  IN termin.zajezd_id%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_termin(
        p_termin_id IN termin.termin_id%TYPE,
        o_result     OUT CLOB
    );

END pck_termin;
/

CREATE OR REPLACE PACKAGE BODY pck_termin AS

    PROCEDURE manage_termin(
        p_termin_id IN OUT termin.termin_id%TYPE,
        p_od         IN termin.od%TYPE,
        p_do         IN termin.do%TYPE,
        p_zajezd_id  IN termin.zajezd_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_termin_id IS NULL THEN
            INSERT INTO termin (od, do, zajezd_id)
            VALUES (p_od, p_do, p_zajezd_id)
            RETURNING termin_id INTO p_termin_id;
            
            o_result := '{ "status": "OK", "message": "Termin byl uspesne vytvoren." }';
        ELSE
            UPDATE termin
            SET od = p_od,
                do = p_do,
                zajezd_id = p_zajezd_id
            WHERE termin_id = p_termin_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: TERMINY_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Termin aktualizovan uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_termin;

    PROCEDURE delete_termin(
        p_termin_id IN termin.termin_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        DELETE FROM termin WHERE termin_id = p_termin_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Termin nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Termin byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_termin;

END pck_termin;
/

CREATE OR REPLACE PACKAGE pck_ubytovani AS

    PROCEDURE manage_ubytovani(
        p_ubytovani_id IN OUT ubytovani.ubytovani_id%TYPE,
        p_nazev        IN ubytovani.nazev%TYPE,
        p_popis        IN ubytovani.popis%TYPE,
        p_adresa_id    IN ubytovani.adresa_id%TYPE,
        p_pocet_hvezd  IN ubytovani.pocet_hvezd%TYPE,
        o_result       OUT CLOB
    );

    PROCEDURE delete_ubytovani(
        p_ubytovani_id IN ubytovani.ubytovani_id%TYPE,
        o_result       OUT CLOB
    );

END pck_ubytovani;
/

CREATE OR REPLACE PACKAGE BODY pck_ubytovani AS

    PROCEDURE manage_ubytovani(
        p_ubytovani_id IN OUT ubytovani.ubytovani_id%TYPE,
        p_nazev        IN ubytovani.nazev%TYPE,
        p_popis        IN ubytovani.popis%TYPE,
        p_adresa_id    IN ubytovani.adresa_id%TYPE,
        p_pocet_hvezd  IN ubytovani.pocet_hvezd%TYPE,
        o_result       OUT CLOB
    ) IS
    BEGIN
        IF p_ubytovani_id IS NULL THEN
            INSERT INTO ubytovani (nazev, popis, adresa_id, pocet_hvezd)
            VALUES (p_nazev, p_popis, p_adresa_id, p_pocet_hvezd)
            RETURNING ubytovani_id INTO p_ubytovani_id;

            o_result := '{ "status": "OK", "message": "Ubytování bylo úspěšně vytvořeno." }';
        ELSE
            UPDATE ubytovani
            SET nazev = p_nazev,
                popis = p_popis,
                adresa_id = p_adresa_id,
                pocet_hvezd = p_pocet_hvezd
            WHERE ubytovani_id = p_ubytovani_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: UBYTOVANI_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Ubytování bylo úspěšně aktualizováno." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_ubytovani;

    PROCEDURE delete_ubytovani(
        p_ubytovani_id IN ubytovani.ubytovani_id%TYPE,
        o_result       OUT CLOB
    ) IS
    BEGIN
        DELETE FROM ubytovani WHERE ubytovani_id = p_ubytovani_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Ubytování nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Ubytování bylo smazáno." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_ubytovani;

END pck_ubytovani;
/

CREATE OR REPLACE PACKAGE pck_zajezd AS

    PROCEDURE manage_zajezd(
        p_zajezd_id   IN OUT zajezd.zajezd_id%TYPE,
        p_popis       IN zajezd.popis%TYPE,
        p_cena_za_osobu IN zajezd.cena_za_osobu%TYPE,
        p_doprava_id  IN zajezd.doprava_id%TYPE,
        p_ubytovani_id IN zajezd.ubytovani_id%TYPE,
        p_strava_id IN zajezd.strava_id%TYPE,
        p_sleva_procent IN zajezd.sleva_procent%TYPE,
        p_zobrazit    IN zajezd.zobrazit%TYPE,
        o_result      OUT CLOB
    );

    PROCEDURE delete_zajezd(
        p_zajezd_id IN zajezd.zajezd_id%TYPE,
        o_result    OUT CLOB
    );

END pck_zajezd;
/

CREATE OR REPLACE PACKAGE BODY pck_zajezd AS

    PROCEDURE manage_zajezd(
        p_zajezd_id   IN OUT zajezd.zajezd_id%TYPE,
        p_popis       IN zajezd.popis%TYPE,
        p_cena_za_osobu IN zajezd.cena_za_osobu%TYPE,
        p_doprava_id  IN zajezd.doprava_id%TYPE,
        p_ubytovani_id IN zajezd.ubytovani_id%TYPE,
        p_strava_id IN zajezd.strava_id%TYPE,
        p_sleva_procent IN zajezd.sleva_procent%TYPE,
        p_zobrazit    IN zajezd.zobrazit%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        IF p_zajezd_id IS NULL THEN
            INSERT INTO zajezd (popis, cena_za_osobu, doprava_id, ubytovani_id, sleva_procent, zobrazit, strava_id)
            VALUES (p_popis, p_cena_za_osobu, p_doprava_id, p_ubytovani_id, p_sleva_procent, p_zobrazit, p_strava_id)
            RETURNING zajezd_id INTO p_zajezd_id;
            
            o_result := '{ "status": "OK", "message": "Zajezd byl uspesne vytvoren." }';
        ELSE
            UPDATE zajezd
            SET popis = p_popis,
                cena_za_osobu = p_cena_za_osobu,
                doprava_id = p_doprava_id,
                ubytovani_id = p_ubytovani_id,
                sleva_procent = p_sleva_procent,
                zobrazit = p_zobrazit,
                strava_id = p_strava_id
            WHERE zajezd_id = p_zajezd_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ZAJEZD_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zajezd aktualizovan uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_zajezd;

    PROCEDURE delete_zajezd(
        p_zajezd_id IN zajezd.zajezd_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zajezd WHERE zajezd_id = p_zajezd_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Zajezd nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zajezd byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_zajezd;

END pck_zajezd;
/

CREATE OR REPLACE PACKAGE pck_zakaznik AS

    PROCEDURE manage_zakaznik(
        p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
        p_prihlasovaci_udaje_id IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_osoba_id IN zakaznik.osoba_id%TYPE,
        p_adresa_id IN zakaznik.adresa_id%TYPE,
        p_kontakt_id IN zakaznik.kontakt_id%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result OUT CLOB
    );

END pck_zakaznik;
/

CREATE OR REPLACE PACKAGE BODY pck_zakaznik AS

    PROCEDURE manage_zakaznik(
        p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
        p_prihlasovaci_udaje_id IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_osoba_id IN zakaznik.osoba_id%TYPE,
        p_adresa_id IN zakaznik.adresa_id%TYPE,
        p_kontakt_id IN zakaznik.kontakt_id%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_zakaznik_id IS NULL THEN
            INSERT INTO zakaznik (
                prihlasovaci_udaje_id,
                osoba_id,
                adresa_id,
                kontakt_id
            ) VALUES (
                p_prihlasovaci_udaje_id,
                p_osoba_id,
                p_adresa_id,
                p_kontakt_id
            ) RETURNING zakaznik_id INTO p_zakaznik_id;

            o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně vytvořen." }';
        ELSE
            UPDATE zakaznik
            SET
                prihlasovaci_udaje_id = p_prihlasovaci_udaje_id,
                osoba_id = p_osoba_id,
                adresa_id = p_adresa_id,
                kontakt_id = p_kontakt_id
            WHERE
                zakaznik_id = p_zakaznik_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Zákazník s daným ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při operaci: ' || SQLERRM || '" }';
    END manage_zakaznik;

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zakaznik WHERE zakaznik_id = p_zakaznik_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Zákazník s daným ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při operaci: ' || SQLERRM || '" }';
    END delete_zakaznik;

END pck_zakaznik;
/

CREATE OR REPLACE PACKAGE pck_zamestnanec AS

    PROCEDURE manage_zamestnanec(
        p_zamestnanec_id IN OUT zamestnanec.zamestnanec_id%TYPE,
        p_role_id       IN zamestnanec.role_id%TYPE,
        p_prihlasovaci_udaje_id    IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        p_prijmeni  IN zamestnanec.prijmeni%TYPE,
        p_jmeno     IN zamestnanec.jmeno%TYPE,
        o_result         OUT CLOB
    );

    PROCEDURE delete_zamestnanec(
        p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE,
        o_result         OUT CLOB
    );

END pck_zamestnanec;
/

CREATE OR REPLACE PACKAGE BODY pck_zamestnanec AS

    PROCEDURE manage_zamestnanec(
        p_zamestnanec_id IN OUT zamestnanec.zamestnanec_id%TYPE,
        p_role_id       IN zamestnanec.role_id%TYPE,
        p_prihlasovaci_udaje_id    IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        p_prijmeni  IN zamestnanec.prijmeni%TYPE,
        p_jmeno     IN zamestnanec.jmeno%TYPE,
        o_result         OUT CLOB
    ) IS
    BEGIN
        IF p_zamestnanec_id IS NULL THEN
            INSERT INTO zamestnanec (role_id, PRIHLASOVACI_UDAJE_ID, nadrizeny_id, prijmeni, jmeno)
            VALUES (p_role_id, p_prihlasovaci_udaje_id, p_nadrizeny_id, p_prijmeni, p_jmeno)
            RETURNING zamestnanec_id INTO p_zamestnanec_id;
            
            o_result := '{ "status": "OK", "message": "Zamestnanec byl uspesne vytvoren." }';
        ELSE
            UPDATE zamestnanec
            SET role_id = p_role_id,
                PRIHLASOVACI_UDAJE_ID = p_prihlasovaci_udaje_id,
                nadrizeny_id = p_nadrizeny_id,
                prijmeni = p_prijmeni,
                jmeno = p_jmeno
            WHERE zamestnanec_id = p_zamestnanec_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ZAMESTNANEC ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zamestnanec aktualizovan �sp?�n?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_zamestnanec;

    PROCEDURE delete_zamestnanec(
        p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE,
        o_result         OUT CLOB
    ) IS
    BEGIN
        UPDATE zamestnanec SET nadrizeny_id = NULL WHERE nadrizeny_id = p_zamestnanec_id;
        
        DELETE FROM zamestnanec WHERE zamestnanec_id = p_zamestnanec_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Zamestnanec nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zamestnanec byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_zamestnanec;

END pck_zamestnanec;
/
