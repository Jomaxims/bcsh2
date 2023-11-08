CREATE OR REPLACE PACKAGE pck_doprava AS

    PROCEDURE manage_doprava(
        p_doprava_id IN OUT doprava.doprava_id%TYPE,
        p_nazev      IN doprava.nazev%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_doprava(
        p_doprava_id IN doprava.doprava_id%TYPE,
        o_result     OUT CLOB
    );

END pck_doprava;
/

CREATE OR REPLACE PACKAGE BODY pck_doprava AS

    PROCEDURE manage_doprava(
        p_doprava_id IN OUT doprava.doprava_id%TYPE,
        p_nazev      IN doprava.nazev%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_doprava_id IS NULL THEN
            INSERT INTO doprava (nazev)
            VALUES (p_nazev)
            RETURNING doprava_id INTO p_doprava_id;
            
            o_result := '{ "status": "OK", "message": "Doprava byla úsp?šn? vytvo?ena." }';
        ELSE
            UPDATE doprava
            SET nazev = p_nazev
            WHERE doprava_id = p_doprava_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: DOPRAVA_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Doprava byla úsp?šn? aktualizována." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END manage_doprava;

    PROCEDURE delete_doprava(
        p_doprava_id IN doprava.doprava_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        DELETE FROM doprava WHERE doprava_id = p_doprava_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Doprava nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Doprava byla smazána." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END delete_doprava;
END pck_doprava;
/
