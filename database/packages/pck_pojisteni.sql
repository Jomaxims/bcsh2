CREATE OR REPLACE PACKAGE pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT pojisteni.pojisteni_id%TYPE,
        p_cena_za_den IN pojisteni.cena_za_den%TYPE,
        p_popis       IN pojisteni.nazev%TYPE,
        o_result      OUT CLOB
    );

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN pojisteni.pojisteni_id%TYPE,
        o_result      OUT CLOB
    );

END pck_pojisteni;
/

CREATE OR REPLACE PACKAGE BODY pck_pojisteni AS

    PROCEDURE manage_pojisteni(
        p_pojisteni_id IN OUT pojisteni.pojisteni_id%TYPE,
        p_cena_za_den IN pojisteni.cena_za_den%TYPE,
        p_popis       IN pojisteni.nazev%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        IF p_pojisteni_id IS NULL THEN
            INSERT INTO pojisteni
                (cena_za_den, nazev)
            VALUES
                (p_cena_za_den, p_popis)
            RETURNING pojisteni_id INTO p_pojisteni_id;

            o_result := '{"status": "OK", "message": "Nové pojistění bylo úspěně vytvořeno."}';
        ELSE
            UPDATE pojisteni
            SET
                cena_za_den = p_cena_za_den,
                nazev = p_popis
            WHERE
                pojisteni_id = p_pojisteni_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Pojistění s daným ID nebylo nalezeno."}';
            ELSE
                o_result := '{"status": "OK", "message": "Pojistění bylo úspěně aktualizováno."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_pojisteni;

    PROCEDURE delete_pojisteni(
        p_pojisteni_id IN pojisteni.pojisteni_id%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        DELETE FROM pojisteni WHERE pojisteni_id = p_pojisteni_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Pojistění s daným ID nebylo nalezeno."}';
        ELSE
            o_result := '{"status": "OK", "message": "Pojistění bylo úspěně smazáno."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_pojisteni;

END pck_pojisteni;
/

