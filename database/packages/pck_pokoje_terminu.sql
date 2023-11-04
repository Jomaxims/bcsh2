CREATE OR REPLACE PACKAGE pck_pokoje_terminy AS

    PROCEDURE manage_pokoje_terminy(
        p_terminy_id IN OUT POKOJE_TERMINU.TERMINY_ID%TYPE,
        p_celkovy_pocet_pokoj IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoj IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
        p_pokoj_id IN POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_pokoje_terminy(
        p_terminy_id IN POKOJE_TERMINU.TERMINY_ID%TYPE,
        o_result OUT CLOB
    );

END pck_pokoje_terminy;
/

CREATE OR REPLACE PACKAGE BODY pck_pokoje_terminy AS

    PROCEDURE manage_pokoje_terminy(
        p_terminy_id IN OUT POKOJE_TERMINU.TERMINY_ID%TYPE,
        p_celkovy_pocet_pokoj IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoj IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
        p_pokoj_id IN POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_terminy_id IS NULL THEN
            INSERT INTO POKOJE_TERMINU (CELKOVY_POCET_POKOJU, POCET_OBSAZENYCH_POKOJU, POKOJ_ID)
            VALUES (p_celkovy_pocet_pokoj, p_pocet_obsazenych_pokoj, p_pokoj_id)
            RETURNING TERMINY_ID INTO p_terminy_id;
            o_result := '{ "status": "OK", "message": "Nov� z�znam byl �sp?�n? vytvo?en." }';
        ELSE
            UPDATE POKOJE_TERMINU
            SET CELKOVY_POCET_POKOJU = p_celkovy_pocet_pokoj,
                POCET_OBSAZENYCH_POKOJU = p_pocet_obsazenych_pokoj
            WHERE TERMINY_ID = p_terminy_id;
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Z�znam s dan�m ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Z�znam byl �sp?�n? aktualizov�n." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || REPLACE(SQLERRM, '"', '\"') || '" }';
    END manage_pokoje_terminy;

    PROCEDURE delete_pokoje_terminy(
        p_terminy_id IN POKOJE_TERMINU.TERMINY_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM POKOJE_TERMINU WHERE TERMINY_ID = p_terminy_id;
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Z�znam s dan�m ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Z�znam byl �sp?�n? smaz�n." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || REPLACE(SQLERRM, '"', '\"') || '" }';
    END delete_pokoje_terminy;

END pck_pokoje_terminy;
/
