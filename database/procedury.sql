SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE stat_package AS

    PROCEDURE manage_stat(
        i_stat_id   IN NUMBER,
        i_zkratka   VARCHAR2,
        i_nazev     VARCHAR2,
        o_result    OUT VARCHAR2
    );
    
    PROCEDURE delete_stat(
        i_stat_id   NUMBER,
        o_result    OUT VARCHAR2
    );

END stat_package;
/


CREATE OR REPLACE PACKAGE BODY stat_package AS

    no_rows_found EXCEPTION;

    PROCEDURE manage_stat(
    i_stat_id   IN NUMBER,
    i_zkratka   VARCHAR2,
    i_nazev     VARCHAR2,
    o_result    OUT VARCHAR2
) IS
BEGIN
    IF i_stat_id IS NULL THEN
        INSERT INTO STAT(ZKRATKA, NAZEV)
        VALUES(i_zkratka, i_nazev);
        o_result := '{ "status": "OK", "message": "Stát p?idán úsp?šn?." }';
    ELSE
        UPDATE STAT
            SET ZKRATKA = i_zkratka, NAZEV = i_nazev
            WHERE STAT_ID = i_stat_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "Stát aktualizován úsp?šn?." }';
        END IF;
    END IF;
EXCEPTION
    WHEN no_rows_found THEN
        o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
    WHEN OTHERS THEN
        o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
END manage_stat;
    
   PROCEDURE delete_stat(
    i_stat_id   IN NUMBER,
    o_result    OUT VARCHAR2
) IS
BEGIN
    IF i_stat_id IS NOT NULL THEN
        DELETE FROM STAT WHERE STAT_ID = i_stat_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "Stát smazán úsp?šn?." }';
        END IF;
    END IF;
EXCEPTION
    WHEN no_rows_found THEN
        o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
    WHEN OTHERS THEN
        o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
END delete_stat;
END stat_package;
/



CREATE OR REPLACE PACKAGE adresa_package AS

    PROCEDURE manage_adresa(
        i_adresa_id     IN INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    );

    PROCEDURE delete_adresa(
        i_adresa_id     IN INTEGER,
        o_result        OUT CLOB
    );

END adresa_package;
/

CREATE OR REPLACE PACKAGE BODY adresa_package AS

    no_rows_found EXCEPTION;

    PROCEDURE manage_adresa(
        i_adresa_id     IN INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF i_adresa_id IS NULL THEN
            INSERT INTO ADRESA(ULICE, CISLO_POPISNE, MESTO, PSC, POZNAMKA, STAT_ID)
                VALUES(i_ulice, i_cislo_popisne, i_mesto, i_psc, i_poznamka, i_stat_id);
                o_result := '{ "status": "OK", "message": "Adresa byla uspesne vytvorena." }';
        ELSE
             UPDATE ADRESA
                SET ULICE = i_ulice,
                    CISLO_POPISNE = i_cislo_popisne,
                    MESTO = i_mesto,
                    PSC = i_psc,
                    POZNAMKA = i_poznamka,
                    STAT_ID = i_stat_id
                WHERE ADRESA_ID = i_adresa_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_adresa;

    PROCEDURE delete_adresa(
        i_adresa_id     IN INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF i_adresa_id IS NOT NULL THEN 
            DELETE FROM ADRESA WHERE ADRESA_ID = i_adresa_id;
        
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa smazána úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_adresa;

END adresa_package;
/


CREATE OR REPLACE PACKAGE osoba_package AS

    PROCEDURE manage_osoba(
        i_adresa_id     IN INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    );

    PROCEDURE delete_osoba(
        i_adresa_id     IN INTEGER,
        o_result        OUT CLOB
    );

END adresa_package;
/

CREATE OR REPLACE PACKAGE BODY adresa_package AS

    no_rows_found EXCEPTION;

    PROCEDURE manage_adresa(
        i_adresa_id     IN INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF i_adresa_id IS NULL THEN
            INSERT INTO ADRESA(ULICE, CISLO_POPISNE, MESTO, PSC, POZNAMKA, STAT_ID)
                VALUES(i_ulice, i_cislo_popisne, i_mesto, i_psc, i_poznamka, i_stat_id);
                o_result := '{ "status": "OK", "message": "Adresa byla uspesne vytvorena." }';
        ELSE
             UPDATE ADRESA
                SET ULICE = i_ulice,
                    CISLO_POPISNE = i_cislo_popisne,
                    MESTO = i_mesto,
                    PSC = i_psc,
                    POZNAMKA = i_poznamka,
                    STAT_ID = i_stat_id
                WHERE ADRESA_ID = i_adresa_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_adresa;

    PROCEDURE delete_adresa(
        i_adresa_id     IN INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF i_adresa_id IS NOT NULL THEN 
            DELETE FROM ADRESA WHERE ADRESA_ID = i_adresa_id;
        
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa smazána úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_adresa;

END adresa_package;
/

CREATE OR REPLACE PACKAGE osoba_package AS

    PROCEDURE manage_osoba(
        i_osoba_id      IN INTEGER,
        i_jmeno         VARCHAR2,
        i_prijmeni      VARCHAR2,
        i_vek           NUMBER,
        i_adresa_id     INTEGER,
        o_result        OUT CLOB
    );

    PROCEDURE delete_osoba(
        i_osoba_id      IN INTEGER,
        o_result        OUT CLOB
    );

END osoba_package;
/

CREATE OR REPLACE PACKAGE BODY osoba_package AS

    no_rows_found EXCEPTION;
    no_address_found EXCEPTION;

    PROCEDURE manage_osoba(
        i_osoba_id      IN INTEGER,
        i_jmeno         VARCHAR2,
        i_prijmeni      VARCHAR2,
        i_vek           NUMBER,
        i_adresa_id     INTEGER,
        o_result        OUT CLOB
    ) IS
        l_adresa_count  INTEGER;
    BEGIN
        SELECT COUNT(*) INTO l_adresa_count FROM ADRESA WHERE ADRESA_ID = i_adresa_id;
        IF l_adresa_count = 0 THEN
            RAISE no_address_found;
        END IF;

        IF i_osoba_id IS NULL THEN
            INSERT INTO OSOBA(JMENO, PRIJMENI, VEK, ADRESA_ID)
                VALUES(i_jmeno, i_prijmeni, i_vek, i_adresa_id);
            o_result := '{ "status": "OK", "message": "Osoba byla uspesne vytvorena." }';
        ELSE
            UPDATE OSOBA
                SET JMENO = i_jmeno,
                    PRIJMENI = i_prijmeni,
                    VEK = i_vek,
                    ADRESA_ID = i_adresa_id
                WHERE OSOBA_ID = i_osoba_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Osoba aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
        WHEN no_address_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_osoba;

    PROCEDURE delete_osoba(
        i_osoba_id      IN INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OSOBA WHERE OSOBA_ID = i_osoba_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "Osoba smazána úsp?šn?." }';
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_osoba;

END osoba_package;
/

CREATE OR REPLACE PACKAGE kontakt_package AS

    PROCEDURE manage_kontakt(
        i_kontakt_id    IN INTEGER,
        i_email         VARCHAR2,
        i_telefon       VARCHAR2,
        i_osoba_id      INTEGER,
        o_result        OUT CLOB
    );

    PROCEDURE delete_kontakt(
        i_kontakt_id    IN INTEGER,
        o_result        OUT CLOB
    );

END kontakt_package;
/

CREATE OR REPLACE PACKAGE BODY kontakt_package AS

    no_rows_found EXCEPTION;
    no_osoba_found EXCEPTION;

    PROCEDURE manage_kontakt(
        i_kontakt_id    IN INTEGER,
        i_email         VARCHAR2,
        i_telefon       VARCHAR2,
        i_osoba_id      INTEGER,
        o_result        OUT CLOB
    ) IS
        l_osoba_count   INTEGER;
    BEGIN
        SELECT COUNT(*) INTO l_osoba_count FROM OSOBA WHERE OSOBA_ID = i_osoba_id;
        IF l_osoba_count = 0 THEN
            RAISE no_osoba_found;
        END IF;

        IF i_kontakt_id IS NULL THEN
            INSERT INTO KONTAKT(EMAIL, TELEFON, OSOBA_ID)
                VALUES(i_email, i_telefon, i_osoba_id);
            o_result := '{ "status": "OK", "message": "Kontakt byl uspesne vytvoren." }';
        ELSE
            UPDATE KONTAKT
                SET EMAIL = i_email,
                    TELEFON = i_telefon,
                    OSOBA_ID = i_osoba_id
                WHERE KONTAKT_ID = i_kontakt_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID kontaktu nebylo nalezeno." }';
        WHEN no_osoba_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_kontakt;

    PROCEDURE delete_kontakt(
        i_kontakt_id    IN INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        DELETE FROM KONTAKT WHERE KONTAKT_ID = i_kontakt_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "Kontakt smazán úsp?šn?." }';
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID kontaktu nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_kontakt;

END kontakt_package;
/

CREATE OR REPLACE PACKAGE udaje_package AS

    PROCEDURE manage_udaje(
        i_udaje_id     IN INTEGER,
        i_jmeno        VARCHAR2,
        i_heslo        VARCHAR2,
        o_result       OUT CLOB
    );

    PROCEDURE delete_udaje(
        i_udaje_id     IN INTEGER,
        o_result       OUT CLOB
    );

END udaje_package;
/

CREATE OR REPLACE PACKAGE BODY udaje_package AS

    no_rows_found EXCEPTION;

    PROCEDURE manage_udaje(
        i_udaje_id     IN INTEGER,
        i_jmeno        VARCHAR2,
        i_heslo        VARCHAR2,
        o_result       OUT CLOB
    ) IS
    BEGIN
        IF i_udaje_id IS NULL THEN
            INSERT INTO UDAJE(JMENO, HESLO)
                VALUES(i_jmeno, i_heslo);
            o_result := '{ "status": "OK", "message": "UJDAE byl uspesne vytvoren." }';
        ELSE
            UPDATE UDAJE
                SET JMENO = i_jmeno,
                    HESLO = i_heslo
                WHERE UDAJE_ID = i_udaje_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "UJDAE aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID UJDAE nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_udaje;

    PROCEDURE delete_udaje(
        i_udaje_id     IN INTEGER,
        o_result       OUT CLOB
    ) IS
    BEGIN
        DELETE FROM UDAJE WHERE UDAJE_ID = i_udaje_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "UJDAE smazán úsp?šn?." }';
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ID UJDAE nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_udaje;

END udaje_package;
/


CREATE OR REPLACE PACKAGE zakaznik_package AS

    PROCEDURE manage_zakaznik(
        i_zakaznik_id   IN INTEGER,
        i_udaje_id      IN INTEGER,
        i_osoba_id      IN INTEGER,
        o_result        OUT CLOB
    );

    PROCEDURE delete_zakaznik(
        i_zakaznik_id   IN INTEGER,
        o_result        OUT CLOB
    );

END zakaznik_package;
/

CREATE OR REPLACE PACKAGE BODY zakaznik_package AS

    no_rows_found EXCEPTION;

    PROCEDURE manage_zakaznik(
        i_zakaznik_id   IN INTEGER,
        i_udaje_id      IN INTEGER,
        i_osoba_id      IN INTEGER,
        o_result        OUT CLOB
    ) IS
        v_udaje_check INTEGER;
        v_osoba_check INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_udaje_check FROM UDAJE WHERE UJDAE_ID = i_udaje_id;
        SELECT COUNT(*) INTO v_osoba_check FROM OSOBA WHERE OSOBA_ID = i_osoba_id;
        
        IF v_udaje_check = 0 OR v_osoba_check = 0 THEN
            RAISE no_rows_found;
        END IF;

        IF i_zakaznik_id IS NULL THEN
            INSERT INTO ZAKAZNIK(UDAJE_ID, OSOBA_ID)
                VALUES(i_udaje_id, i_osoba_id);
            o_result := '{ "status": "OK", "message": "ZAKAZNIK byl uspesne vytvoren." }';
        ELSE
            UPDATE ZAKAZNIK
                SET UDAJE_ID = i_udaje_id,
                    OSOBA_ID  = i_osoba_id
                WHERE ZAKAZNIK_ID = i_zakaznik_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                RAISE no_rows_found;
            ELSE
                o_result := '{ "status": "OK", "message": "ZAKAZNIK aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: UDAJE_ID nebo OSOBA_ID neexistuje nebo ZAKAZNIK ID nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_zakaznik;

    PROCEDURE delete_zakaznik(
        i_zakaznik_id   IN INTEGER,
        o_result        OUT CLOB
    ) IS
        v_udaje_id INTEGER;
    BEGIN
        SELECT UDAJE_ID INTO v_udaje_id FROM ZAKAZNIK WHERE ZAKAZNIK_ID = i_zakaznik_id;

        DELETE FROM ZAKAZNIK WHERE ZAKAZNIK_ID = i_zakaznik_id;
        DELETE FROM UJDAE WHERE UJDAE_ID = v_udaje_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_rows_found;
        ELSE
            o_result := '{ "status": "OK", "message": "ZAKAZNIK and associated UDAJE smazán úsp?šn?." }';
        END IF;
    EXCEPTION
        WHEN no_rows_found THEN
            o_result := '{ "status": "error", "message": "Chyba: ZAKAZNIK ID or UDAJE_ID nebylo nalezeno." }';
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_zakaznik;

END zakaznik_package;
/
     

DECLARE
    v_stat_id  NUMBER:= 6;--jenom NUMBER pro insert
    v_result   VARCHAR2(100);
BEGIN
    stat_package.manage_stat(
        i_stat_id   => v_stat_id,
        i_zkratka   => 'PL',
        i_nazev     => 'Polsko',
        o_result    => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_stat_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


DECLARE
 v_stat_id  NUMBER:= 5;
 v_result VARCHAR2(100);
BEGIN
    stat_package.delete_stat(
        i_stat_id => v_stat_id,
        o_result  => v_result
    );

    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/



DECLARE
    v_result CLOB;
    v_adresa_id INTEGER;
BEGIN
    adresa_package.manage_adresa(
        i_adresa_id =>  v_adresa_id,
        i_ulice => 'Na Prikope',
        i_cislo_popisne => '1234',
        i_mesto => 'Praha',
        i_psc => '11000',
        i_poznamka => 'Centrum Prahy',
        i_stat_id => 1,
        o_result => v_result
    );
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
  v_result CLOB;
  v_osoba_id INTEGER;
BEGIN

  PROCEDURY_OSOBA.manage_osoba(
    i_osoba_id => v_osoba_id,
    i_jmeno => 'Pepa',
    i_prijmeni => 'Zdepa',
    i_vek => 30,
    i_adresa_id => 1,
    o_result => v_result
  );
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/







