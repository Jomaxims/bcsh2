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
