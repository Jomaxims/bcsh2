CREATE OR REPLACE PACKAGE pck_termin AS

    PROCEDURE manage_termin(
        p_terminy_id IN OUT termin.terminy_id%TYPE,
        p_od         IN termin.od%TYPE,
        p_do         IN termin.do%TYPE,
        p_zajezd_id  IN termin.zajezd_id%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_termin(
        p_terminy_id IN termin.terminy_id%TYPE,
        o_result     OUT CLOB
    );

END pck_termin;
/

CREATE OR REPLACE PACKAGE BODY pck_termin AS

    PROCEDURE manage_termin(
        p_terminy_id IN OUT termin.terminy_id%TYPE,
        p_od         IN termin.od%TYPE,
        p_do         IN termin.do%TYPE,
        p_zajezd_id  IN termin.zajezd_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_terminy_id IS NULL THEN
            INSERT INTO termin (od, do, zajezd_id)
            VALUES (p_od, p_do, p_zajezd_id)
            RETURNING terminy_id INTO p_terminy_id;
            
            o_result := '{ "status": "OK", "message": "Termin byl uspesne vytvoren." }';
        ELSE
            UPDATE termin
            SET od = p_od,
                do = p_do,
                zajezd_id = p_zajezd_id
            WHERE terminy_id = p_terminy_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: TERMINY_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Termin aktualizovan uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_termin;

    PROCEDURE delete_termin(
        p_terminy_id IN termin.terminy_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        DELETE FROM termin WHERE terminy_id = p_terminy_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Termin nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Termin byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_termin;

END pck_termin;
/
