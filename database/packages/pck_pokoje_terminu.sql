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

END pck_pokoje_terminu;
/

