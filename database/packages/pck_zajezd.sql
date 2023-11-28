CREATE OR REPLACE PACKAGE pck_zajezd AS

    PROCEDURE manage_zajezd(
        p_zajezd_id   IN OUT zajezd.zajezd_id%TYPE,
        p_popis       IN zajezd.popis%TYPE,
        p_cena_za_osobu IN zajezd.cena_za_osobu%TYPE,
        p_doprava_id  IN zajezd.doprava_id%TYPE,
        p_ubytovani_id IN zajezd.ubytovani_id%TYPE,
        p_strava_id IN zajezd.strava_id%TYPE,
        p_sleva_procent IN zajezd.sleva_procent%TYPE,
        p_zobrazit    IN zajezd.zobrazit%TYPE,
        o_result      OUT CLOB
    );

    PROCEDURE delete_zajezd(
        p_zajezd_id IN zajezd.zajezd_id%TYPE,
        o_result    OUT CLOB
    );

END pck_zajezd;
/

CREATE OR REPLACE PACKAGE BODY pck_zajezd AS

    PROCEDURE manage_zajezd(
        p_zajezd_id   IN OUT zajezd.zajezd_id%TYPE,
        p_popis       IN zajezd.popis%TYPE,
        p_cena_za_osobu IN zajezd.cena_za_osobu%TYPE,
        p_doprava_id  IN zajezd.doprava_id%TYPE,
        p_ubytovani_id IN zajezd.ubytovani_id%TYPE,
        p_strava_id IN zajezd.strava_id%TYPE,
        p_sleva_procent IN zajezd.sleva_procent%TYPE,
        p_zobrazit    IN zajezd.zobrazit%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        IF p_zajezd_id IS NULL THEN
            INSERT INTO zajezd (popis, cena_za_osobu, doprava_id, ubytovani_id, sleva_procent, zobrazit, strava_id)
            VALUES (p_popis, p_cena_za_osobu, p_doprava_id, p_ubytovani_id, p_sleva_procent, p_zobrazit, p_strava_id)
            RETURNING zajezd_id INTO p_zajezd_id;
            
            o_result := '{ "status": "OK", "message": "Zajezd byl uspesne vytvoren." }';
        ELSE
            UPDATE zajezd
            SET popis = p_popis,
                cena_za_osobu = p_cena_za_osobu,
                doprava_id = p_doprava_id,
                ubytovani_id = p_ubytovani_id,
                sleva_procent = p_sleva_procent,
                zobrazit = p_zobrazit,
                strava_id = p_strava_id
            WHERE zajezd_id = p_zajezd_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ZAJEZD_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zajezd aktualizovan uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_zajezd;

    PROCEDURE delete_zajezd(
        p_zajezd_id IN zajezd.zajezd_id%TYPE,
        o_result    OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zajezd WHERE zajezd_id = p_zajezd_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Zajezd nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zajezd byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_zajezd;

END pck_zajezd;
/
