CREATE OR REPLACE PACKAGE pck_obrazky_ubytoavni AS

    PROCEDURE manage_obrazek(
        p_obrazky_ubytoavni_id IN OUT OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE,
        p_obrazek BLOB,
        p_poradi IN OBRAZKY_UBYTOVANI.PORADI%TYPE,
        p_ubytoavni_id IN OBRAZKY_UBYTOVANI.UBYTOVANI_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_obrazek(
        p_obrazky_ubytoavni_id IN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE,
        o_result OUT CLOB
    );

END pck_obrazky_ubytoavni;
/

CREATE OR REPLACE PACKAGE BODY pck_obrazky_ubytoavni AS

    PROCEDURE manage_obrazek(
        p_obrazky_ubytoavni_id IN OUT OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE,
        p_obrazek BLOB,
        p_poradi IN OBRAZKY_UBYTOVANI.PORADI%TYPE,
        p_ubytoavni_id IN OBRAZKY_UBYTOVANI.UBYTOVANI_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_obrazky_ubytoavni_id IS NULL THEN
            INSERT INTO OBRAZKY_UBYTOVANI (OBRAZEK, PORADI, UBYTOVANI_ID)
            VALUES (p_obrazek, p_poradi, p_ubytoavni_id)
            RETURNING OBRAZKY_UBYTOVANI_ID INTO p_obrazky_ubytoavni_id;
            
            o_result := '{ "status": "OK", "message": "Nový obrázek byl úsp?šn? vytvo?en." }';
        ELSE
            UPDATE OBRAZKY_UBYTOVANI
            SET OBRAZEK = p_obrazek,
                PORADI = p_poradi,
                UBYTOVANI_ID = p_ubytoavni_id
            WHERE OBRAZKY_UBYTOVANI_ID = p_obrazky_ubytoavni_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Obrázek s daným ID nebyl nalezen." }';
            ELSE
                -- Return success message in Czech
                o_result := '{ "status": "OK", "message": "Obrázek byl úsp?šn? aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END manage_obrazek;

    PROCEDURE delete_obrazek(
        p_obrazky_ubytoavni_id IN OBRAZKY_UBYTOVANI.OBRAZKY_UBYTOVANI_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OBRAZKY_UBYTOVANI WHERE OBRAZKY_UBYTOVANI_ID = p_obrazky_ubytoavni_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Obrázek s daným ID nebyl nalezen." }';
        ELSE
            -- Return success message in Czech
            o_result := '{ "status": "OK", "message": "Obrázek byl úsp?šn? smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END delete_obrazek;

END pck_obrazky_ubytoavni;
/
