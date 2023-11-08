CREATE OR REPLACE PACKAGE pck_prihlasovaci_udaje AS

    PROCEDURE manage_prihlasovaci_udaje(
    p_prihlasovaci_udaje_id IN OUT prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
    p_jmeno    IN prihlasovaci_udaje.jmeno%TYPE,
    p_heslo    IN prihlasovaci_udaje.heslo%TYPE,
    o_result   OUT CLOB
    );

    PROCEDURE delete_prihlasovaci_udaje(
        p_prihlasovaci_udaje_id IN prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
        o_result   OUT CLOB
    );

END pck_prihlasovaci_udaje;
/

CREATE OR REPLACE PACKAGE BODY pck_prihlasovaci_udaje AS

 PROCEDURE manage_prihlasovaci_udaje(
    p_prihlasovaci_udaje_id IN OUT prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
    p_jmeno    IN prihlasovaci_udaje.jmeno%TYPE,
    p_heslo    IN prihlasovaci_udaje.heslo%TYPE,
    o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_prihlasovaci_udaje_id IS NULL THEN
            INSERT INTO prihlasovaci_udaje
                  (jmeno, heslo)
            VALUES (p_jmeno, p_heslo)
            RETURNING prihlasovaci_udaje_id INTO p_prihlasovaci_udaje_id;

            o_result := '{ "status": "OK", "message": "Údaje byly úsp?šn? vytvo?eny." }';
        ELSE
            UPDATE prihlasovaci_udaje
            SET    jmeno = p_jmeno,
                   heslo = p_heslo
            WHERE  prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje aktualizovány úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_prihlasovaci_udaje;

    PROCEDURE delete_prihlasovaci_udaje(
       p_prihlasovaci_udaje_id IN prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_prihlasovaci_udaje_id IS NOT NULL THEN
            DELETE FROM prihlasovaci_udaje WHERE prihlasovaci_udaje_id = p_prihlasovaci_udaje_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID údaje nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Údaje smazány úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_prihlasovaci_udaje;

END pck_prihlasovaci_udaje;
/
