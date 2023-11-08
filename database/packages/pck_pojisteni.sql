CREATE OR REPLACE PACKAGE pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT POJISTENI.POJISTENI_ID%TYPE,
        p_cena_za_den IN POJISTENI.CENA_ZA_DEN%TYPE,
        p_popis IN POJISTENI.POPIs%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN POJISTENI.POJISTENI_ID%TYPE,
        o_result OUT CLOB
    );

END pck_pojisteni;
/

CREATE OR REPLACE PACKAGE BODY pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT POJISTENI.POJISTENI_ID%TYPE,
        p_cena_za_den IN POJISTENI.CENA_ZA_DEN%TYPE,
        p_popis IN POJISTENI.POPIs%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_pojisteni_id IS NULL THEN
            INSERT INTO POJISTENI
                (CENA_ZA_DEN, POPIs)
            VALUES
                (p_cena_za_den, p_popis)
            RETURNING POJISTENI_ID INTO p_pojisteni_id;

            o_result := '{ "status": "OK", "message": "Nové pojist?ní bylo úsp?šn? vytvo?eno." }';
        ELSE
            UPDATE POJISTENI
            SET
                CENA_ZA_DEN = p_cena_za_den,
                POPIs = p_popis
            WHERE
                POJISTENI_ID = p_pojisteni_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Pojist?ní s daným ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Pojist?ní bylo úsp?šn? aktualizováno." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END manage_pojisteni;

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN POJISTENI.POJISTENI_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM POJISTENI WHERE POJISTENI_ID = p_pojisteni_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Pojist?ní s daným ID nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Pojist?ní bylo úsp?šn? smazáno." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END delete_pojisteni;

END pck_pojisteni;
/
