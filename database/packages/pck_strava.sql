CREATE OR REPLACE PACKAGE pck_strava AS

    PROCEDURE manage_strava(
        p_strava_id IN OUT strava.strava_id%TYPE,
        p_nazev     IN strava.nazev%TYPE,
        o_result    OUT CLOB
    );

    PROCEDURE delete_strava(
        p_strava_id IN strava.strava_id%TYPE,
        o_result    OUT CLOB
    );

END pck_strava;
/

CREATE OR REPLACE PACKAGE BODY pck_strava AS

    PROCEDURE manage_strava(
        p_strava_id IN OUT strava.strava_id%TYPE,
        p_nazev     IN strava.nazev%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        IF p_strava_id IS NULL THEN
            INSERT INTO strava (nazev)
            VALUES (p_nazev)
            RETURNING strava_id INTO p_strava_id;
            
            o_result := '{ "status": "OK", "message": "Strava byla uspesne vytvorena." }';
        ELSE
            UPDATE strava
            SET nazev = p_nazev
            WHERE strava_id = p_strava_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Strava ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Strava aktualizovana úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_strava;

    PROCEDURE delete_strava(
        p_strava_id IN strava.strava_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        DELETE FROM strava WHERE strava_id = p_strava_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Strava nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Strava byla smazana." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_strava;

END pck_strava;
/
