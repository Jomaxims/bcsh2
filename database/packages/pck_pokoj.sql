CREATE OR REPLACE PACKAGE pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id IN OUT POKOJ.POKOJ_ID%TYPE,
        p_pocet_mist IN POKOJ.POCET_MIST%TYPE,
        p_nazev IN POKOJ.NAZEV%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_pokoj(
        p_pokoj_id IN POKOJ.POKOJ_ID%TYPE,
        o_result OUT CLOB
    );

END pck_pokoj;
/

CREATE OR REPLACE PACKAGE BODY pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id IN OUT POKOJ.POKOJ_ID%TYPE,
        p_pocet_mist IN POKOJ.POCET_MIST%TYPE,
        p_nazev IN POKOJ.NAZEV%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_pokoj_id IS NULL THEN
            INSERT INTO POKOJ (POCET_MIST, NAZEV)
            VALUES (p_pocet_mist, p_nazev)
            RETURNING POKOJ_ID INTO p_pokoj_id;
            o_result := '{ "status": "OK", "message": "Nov� pokoj byl �sp?�n? vytvo?en." }';
        ELSE
            UPDATE POKOJ
            SET POCET_MIST = p_pocet_mist,
                NAZEV = p_nazev
            WHERE POKOJ_ID = p_pokoj_id;
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Pokoj s dan�m ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Pokoj byl �sp?�n? aktualizov�n." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || SQLERRM || '" }';
    END manage_pokoj;

    PROCEDURE delete_pokoj(
        p_pokoj_id IN POKOJ.POKOJ_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM POKOJ WHERE POKOJ_ID = p_pokoj_id;
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Pokoj s dan�m ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Pokoj byl �sp?�n? smaz�n." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || SQLERRM || '" }';
    END delete_pokoj;

END pck_pokoj;
/
