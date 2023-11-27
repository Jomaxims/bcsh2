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
            -- Return success message in Czech
            o_result := '{ "status": "OK", "message": "Obrázek byl úspěšně smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END delete_obrazky_ubytovani;

END pck_obrazky_ubytovani;
/
