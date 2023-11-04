CREATE OR REPLACE PACKAGE pck_strava_zajezdu AS

    PROCEDURE manage_strava_zajezdu(
        p_strava_id  IN OUT strava_zajezdu.strava_id%TYPE,
        p_zajezd_id  IN strava_zajezdu.zajezd_id%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_strava_zajezdu(
        p_strava_id IN strava_zajezdu.strava_id%TYPE,
        p_zajezd_id IN strava_zajezdu.zajezd_id%TYPE,
        o_result    OUT CLOB
    );

END pck_strava_zajezdu;
/

CREATE OR REPLACE PACKAGE BODY pck_strava_zajezdu AS

    PROCEDURE manage_strava_zajezdu(
        p_strava_id  IN OUT strava_zajezdu.strava_id%TYPE,
        p_zajezd_id  IN strava_zajezdu.zajezd_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        BEGIN
            SELECT strava_id INTO p_strava_id FROM strava_zajezdu 
            WHERE strava_id = p_strava_id AND zajezd_id = p_zajezd_id FOR UPDATE;
            
            UPDATE strava_zajezdu
            SET zajezd_id = p_zajezd_id
            WHERE strava_id = p_strava_id AND zajezd_id = p_zajezd_id;
            
            o_result := '{ "status": "OK", "message": "Strava_Zajezdu aktualizovana úsp?šn?." }';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO strava_zajezdu (strava_id, zajezd_id)
                VALUES (p_strava_id, p_zajezd_id);
                
                o_result := '{ "status": "OK", "message": "Strava_Zajezdu byla uspesne vytvorena." }';
        END;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_strava_zajezdu;

    PROCEDURE delete_strava_zajezdu(
        p_strava_id IN strava_zajezdu.strava_id%TYPE,
        p_zajezd_id IN strava_zajezdu.zajezd_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        DELETE FROM strava_zajezdu WHERE strava_id = p_strava_id AND zajezd_id = p_zajezd_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Zaznam nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zaznam byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_strava_zajezdu;

END pck_strava_zajezdu;
/
