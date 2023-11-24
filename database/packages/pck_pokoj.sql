CREATE OR REPLACE PACKAGE pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id   IN OUT pokoj.pokoj_id%TYPE,
        p_pocet_mist IN pokoj.pocet_mist%TYPE,
        p_nazev      IN pokoj.nazev%TYPE,
        o_result     OUT CLOB
    );

    PROCEDURE delete_pokoj(
        p_pokoj_id   IN pokoj.pokoj_id%TYPE,
        o_result     OUT CLOB
    );

END pck_pokoj;
/

CREATE OR REPLACE PACKAGE BODY pck_pokoj AS

    PROCEDURE manage_pokoj(
        p_pokoj_id   IN OUT pokoj.pokoj_id%TYPE,
        p_pocet_mist IN pokoj.pocet_mist%TYPE,
        p_nazev      IN pokoj.nazev%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_pokoj_id IS NULL THEN
            INSERT INTO pokoj (pocet_mist, nazev)
            VALUES (p_pocet_mist, p_nazev)
            RETURNING pokoj_id INTO p_pokoj_id;
            o_result := '{"status": "OK", "message": "Nový pokoj byl úspěně vytvořen."}';
        ELSE
            UPDATE pokoj
            SET pocet_mist = p_pocet_mist,
                nazev = p_nazev
            WHERE pokoj_id = p_pokoj_id;
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Pokoj s daným ID nebyl nalezen."}';
            ELSE
                o_result := '{"status": "OK", "message": "Pokoj byl úspěně aktualizován."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_pokoj;

    PROCEDURE delete_pokoj(
        p_pokoj_id   IN pokoj.pokoj_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        DELETE FROM pokoj WHERE pokoj_id = p_pokoj_id;
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Pokoj s daným ID nebyl nalezen."}';
        ELSE
            o_result := '{"status": "OK", "message": "Pokoj byl úspěně smazán."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_pokoj;

END pck_pokoj;
/

