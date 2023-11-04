CREATE OR REPLACE PACKAGE pck_udaje AS

    PROCEDURE manage_udaje(
    p_udaje_id IN OUT udaje.udaje_id%TYPE,
    p_jmeno    IN udaje.jmeno%TYPE,
    p_heslo    IN udaje.heslo%TYPE,
    o_result   OUT CLOB
    );

    PROCEDURE delete_udaje(
        p_udaje_id IN udaje.udaje_id%TYPE,
        o_result   OUT CLOB
    );

END pck_udaje;
/

CREATE OR REPLACE PACKAGE BODY pck_udaje AS

 PROCEDURE manage_udaje(
    p_udaje_id IN OUT udaje.udaje_id%TYPE,
    p_jmeno    IN udaje.jmeno%TYPE,
    p_heslo    IN udaje.heslo%TYPE,
    o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_udaje_id IS NULL THEN
            INSERT INTO udaje
                  (jmeno, heslo)
            VALUES (p_jmeno, p_heslo)
            RETURNING udaje_id INTO p_udaje_id;

            o_result := '{ "status": "OK", "message": "Údaje byly úsp?šn? vytvo?eny." }';
        ELSE
            UPDATE udaje
            SET    jmeno = p_jmeno,
                   heslo = p_heslo
            WHERE  udaje_id = p_udaje_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje aktualizovány úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_udaje;

    PROCEDURE delete_udaje(
        p_udaje_id IN udaje.udaje_id%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_udaje_id IS NOT NULL THEN
            DELETE FROM udaje WHERE udaje_id = p_udaje_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje smazány úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_udaje;

END pck_udaje;
/
