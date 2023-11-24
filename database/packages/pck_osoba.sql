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
