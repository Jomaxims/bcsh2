CREATE OR REPLACE PACKAGE pck_pokoje_terminu AS

    PROCEDURE manage_pokoje_terminu(
        p_termin_id IN OUT POKOJE_TERMINU.TERMIN_ID%TYPE,
        p_celkovy_pocet_pokoj IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoj IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
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
        p_celkovy_pocet_pokoj IN POKOJE_TERMINU.CELKOVY_POCET_POKOJU%TYPE,
        p_pocet_obsazenych_pokoj IN POKOJE_TERMINU.POCET_OBSAZENYCH_POKOJU%TYPE,
        p_pokoj_id IN OUT POKOJE_TERMINU.POKOJ_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_termin_id IS NULL THEN
            INSERT INTO POKOJE_TERMINU (CELKOVY_POCET_POKOJU, POCET_OBSAZENYCH_POKOJU, POKOJ_ID, TERMIN_ID)
            VALUES (p_celkovy_pocet_pokoj, p_pocet_obsazenych_pokoj, p_pokoj_id, p_termin_id)
            RETURNING TERMIN_ID, POKOJ_ID INTO p_termin_id, p_pokoj_id;
            o_result := '{ "status": "OK", "message": "Nový záznam byl úspěně vytvořen." }';
        ELSE
            UPDATE POKOJE_TERMINU
            SET CELKOVY_POCET_POKOJU = p_celkovy_pocet_pokoj,
                POCET_OBSAZENYCH_POKOJU = p_pocet_obsazenych_pokoj
            WHERE TERMIN_ID = p_termin_id and POKOJ_ID = p_pokoj_id;
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Záznam s daným ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Záznam byl úspěně aktualizován." }';
            END IF;
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

