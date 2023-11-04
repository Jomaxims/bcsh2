CREATE OR REPLACE PACKAGE pck_ubytovani AS

    PROCEDURE manage_ubytovani(
        p_ubytovani_id IN OUT ubytovani.ubytovani_id%TYPE,
        p_nazev        IN ubytovani.nazev%TYPE,
        p_popis        IN ubytovani.popis%TYPE,
        p_kapacita     IN ubytovani.kapacita%TYPE,
        p_obsazenost   IN ubytovani.obsazenost%TYPE,
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
        p_kapacita     IN ubytovani.kapacita%TYPE,
        p_obsazenost   IN ubytovani.obsazenost%TYPE,
        p_adresa_id    IN ubytovani.adresa_id%TYPE,
        p_pocet_hvezd  IN ubytovani.pocet_hvezd%TYPE,
        o_result       OUT CLOB
    ) IS
    BEGIN
        IF p_ubytovani_id IS NULL THEN
            INSERT INTO ubytovani (nazev, popis, kapacita, obsazenost, adresa_id, pocet_hvezd)
            VALUES (p_nazev, p_popis, p_kapacita, p_obsazenost, p_adresa_id, p_pocet_hvezd)
            RETURNING ubytovani_id INTO p_ubytovani_id;
            
            o_result := '{ "status": "OK", "message": "Ubytovani bylo uspesne vytvoreno." }';
        ELSE
            UPDATE ubytovani
            SET nazev = p_nazev,
                popis = p_popis,
                kapacita = p_kapacita,
                obsazenost = p_obsazenost,
                adresa_id = p_adresa_id,
                pocet_hvezd = p_pocet_hvezd
            WHERE ubytovani_id = p_ubytovani_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: UBYTOVANI_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Ubytovani aktualizovano uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_ubytovani;

    PROCEDURE delete_ubytovani(
        p_ubytovani_id IN ubytovani.ubytovani_id%TYPE,
        o_result       OUT CLOB
    ) IS
    BEGIN
        DELETE FROM ubytovani WHERE ubytovani_id = p_ubytovani_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Ubytovani nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Ubytovani bylo smazano." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_ubytovani;

END pck_ubytovani;
/
