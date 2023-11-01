SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE PROCEDURY_OSOBA AS 

  PROCEDURE add_osoba(
      i_osoba_id INTEGER,
      i_jmeno VARCHAR2,
      i_prijmeni VARCHAR2,
      i_vek NUMBER,
      i_adresa_id INTEGER,
      o_result OUT CLOB
  );

  PROCEDURE update_osoba(
      i_osoba_id INTEGER,
      i_jmeno VARCHAR2,
      i_prijmeni VARCHAR2,
      i_vek NUMBER,
      i_adresa_id INTEGER,
      o_result OUT CLOB
  );

END PROCEDURY_OSOBA;
/


CREATE OR REPLACE PACKAGE BODY PROCEDURY_OSOBA AS

PROCEDURE add_osoba(
    i_osoba_id INTEGER,
    i_jmeno VARCHAR2,
    i_prijmeni VARCHAR2,
    i_vek NUMBER,
    i_adresa_id INTEGER,
    o_result OUT CLOB
) IS
    v_adresa_exists INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_adresa_exists
    FROM ADRESA
    WHERE adresa_id = i_adresa_id;

    IF v_adresa_exists > 0 THEN
        INSERT INTO OSOBA(OSOBA_ID, jmeno, prijmeni, vek, ADRESA_ADRESA_ID)
        VALUES (i_osoba_id, i_jmeno, i_prijmeni, i_vek, i_adresa_id);
        o_result := 'Osoba byla úsp?šn? vložena.';
    ELSE
        o_result := 'Adresa neexistuje. Osoba nem?že být vložena.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_result := 'Chyba: ' || SQLERRM;
END add_osoba;

PROCEDURE update_osoba(
    i_osoba_id INTEGER,
    i_jmeno VARCHAR2,
    i_prijmeni VARCHAR2,
    i_vek NUMBER,
    i_adresa_id INTEGER,
    o_result OUT CLOB
) IS
    v_adresa_exists INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_adresa_exists
    FROM ADRESA
    WHERE adresa_id = i_adresa_id;

    IF v_adresa_exists > 0 THEN
        UPDATE OSOBA
        SET 
            jmeno = i_jmeno,
            prijmeni = i_prijmeni,
            vek = i_vek,
            ADRESA_ADRESA_ID = i_adresa_id
        WHERE osoba_id = i_osoba_id;

       o_result := 'Osoba byla úsp?šn? vložena.';
    ELSE
        o_result := 'Adresa neexistuje. Osoba nem?že být vložena.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_result := 'Chyba p?i aktualizaci: ' || SQLERRM;
END update_osoba;

END PROCEDURY_OSOBA;
/





CREATE OR REPLACE PACKAGE stat_package AS

    PROCEDURE add_stat(
        i_stat_id   NUMBER,
        i_zkratka   VARCHAR2,
        i_nazev     VARCHAR2,
        o_result    OUT VARCHAR2
    );

    PROCEDURE update_stat(
        i_stat_id   NUMBER,
        i_zkratka   VARCHAR2,
        i_nazev     VARCHAR2,
        o_result    OUT VARCHAR2
    );

END stat_package;
/

CREATE OR REPLACE PACKAGE BODY stat_package AS

    PROCEDURE add_stat(
        i_stat_id   NUMBER,
        i_zkratka   VARCHAR2,
        i_nazev     VARCHAR2,
        o_result    OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO STAT(STAT_ID, ZKRATKA, NAZEV)
        VALUES(i_stat_id, i_zkratka, i_nazev);

        o_result := 'Stát p?idán úsp?šn?.';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := 'Chyba p?i p?idávání státu: ' || SQLERRM;
    END add_stat;

    PROCEDURE update_stat(
        i_stat_id   NUMBER,
        i_zkratka   VARCHAR2,
        i_nazev     VARCHAR2,
        o_result    OUT VARCHAR2
    ) AS
    BEGIN
        UPDATE STAT
        SET ZKRATKA = i_zkratka, NAZEV = i_nazev
        WHERE STAT_ID = i_stat_id;

        o_result := 'Stát aktualizován úsp?šn?.';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := 'Chyba p?i aktualizování státu: ' || SQLERRM;
    END update_stat;

END stat_package;
/






-- Specifikace balí?ku
CREATE OR REPLACE PACKAGE adresa_package AS

    -- Procedura pro p?idání nové adresy
    PROCEDURE add_adresa(
        i_adresa_id     INTEGER,
        i_ulice        VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto        VARCHAR2,
        i_psc          VARCHAR2,
        i_poznamka     VARCHAR2,
        i_stat_id      INTEGER,
        o_result       OUT CLOB
    );

    -- Procedura pro aktualizaci existující adresy
    PROCEDURE update_adresa(
        i_adresa_id     INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    );

END adresa_package;
/

-- T?lo balí?ku
CREATE OR REPLACE PACKAGE BODY adresa_package AS

    -- Procedura pro p?idání nové adresy
    PROCEDURE add_adresa(
        i_adresa_id     INTEGER,
        i_ulice        VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto        VARCHAR2,
        i_psc          VARCHAR2,
        i_poznamka     VARCHAR2,
        i_stat_id      INTEGER,
        o_result       OUT CLOB
    ) IS
    BEGIN
        INSERT INTO ADRESA(ADRESA_ID, ULICE, CISLO_POPISNE, MESTO, PSC, POZNAMKA, STAT_STAT_ID)
        VALUES(i_adresa_id, i_ulice, i_cislo_popisne, i_mesto, i_psc, i_poznamka, i_stat_id);

        o_result := 'Adresa byla úsp?šn? vytvo?ena.';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := 'Chyba p?i vytvá?ení adresy: ' || SQLERRM;
    END add_adresa;

    -- Procedura pro aktualizaci existující adresy
    PROCEDURE update_adresa(
        i_adresa_id     INTEGER,
        i_ulice         VARCHAR2,
        i_cislo_popisne VARCHAR2,
        i_mesto         VARCHAR2,
        i_psc           VARCHAR2,
        i_poznamka      VARCHAR2,
        i_stat_id       INTEGER,
        o_result        OUT CLOB
    ) IS
    BEGIN
        UPDATE ADRESA
        SET ULICE = i_ulice,
            CISLO_POPISNE = i_cislo_popisne,
            MESTO = i_mesto,
            PSC = i_psc,
            POZNAMKA = i_poznamka,
            STAT_STAT_ID = i_stat_id
        WHERE ADRESA_ID = i_adresa_id;

        IF SQL%ROWCOUNT > 0 THEN
            o_result := 'Adresa byla úsp?šn? aktualizována.';
        ELSE
            o_result := 'Adresa s daným ID nebyla nalezena.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := 'Chyba p?i aktualizaci adresy: ' || SQLERRM;
    END update_adresa;

END adresa_package;
/




DECLARE
  v_result VARCHAR2(100);
BEGIN
  stat_package.add_stat(
    i_stat_id => STAT_STAT_ID_SEQ.NEXTVAL,
    i_zkratka => 'CZ',
    i_nazev => '?eská republika',
    o_result => v_result
  );
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


DECLARE
    v_result CLOB;
BEGIN
    adresa_package.add_adresa(
        i_adresa_id => ADRESA_ADRESA_ID_SEQ.NEXTVAL,
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

DECLARE
  v_result CLOB;
  v_adresa_id INTEGER;
BEGIN
  SELECT ADRESA_ID INTO v_adresa_id FROM ADRESA WHERE ULICE = 'Na Prikope';

  PROCEDURY_OSOBA.add_osoba(
    i_osoba_id => OSOBA_OSOBA_ID_SEQ.NEXTVAL,
    i_jmeno => 'Pepa',
    i_prijmeni => 'Zdepa',
    i_vek => 30,
    i_adresa_id => v_adresa_id,
    o_result => v_result
  );
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/










