CREATE OR REPLACE PACKAGE pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id        IN OUT platba.platba_id%TYPE,
        p_castka           IN platba.castka%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        p_objednavka_id    IN platba.objednavka_id%TYPE,
        p_zaplacena        IN platba.zaplacena%TYPE,
        o_result           OUT CLOB
    );
    
    PROCEDURE zaplat_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        o_result           OUT CLOB
    );

    PROCEDURE delete_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        o_result           OUT CLOB
    );

END pck_platba;
/

CREATE OR REPLACE PACKAGE BODY pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id        IN OUT platba.platba_id%TYPE,
        p_castka           IN platba.castka%TYPE,
        p_cislo_uctu       IN platba.cislo_uctu%TYPE,
        p_objednavka_id    IN platba.objednavka_id%TYPE,
        p_zaplacena        IN platba.zaplacena%TYPE,
        o_result           OUT CLOB
    ) IS
    BEGIN
        IF p_platba_id IS NULL THEN
            INSERT INTO platba
                (castka, cislo_uctu, objednavka_id, zaplacena)
            VALUES
                (p_castka, p_cislo_uctu, p_objednavka_id, p_zaplacena)
            RETURNING platba_id INTO p_platba_id;

            o_result := '{"status": "OK", "message": "Nová platba byla úspěně vytvořena."}';
        ELSE
            UPDATE platba
            SET
                castka = p_castka,
                cislo_uctu = p_cislo_uctu,
                objednavka_id = p_objednavka_id,
                zaplacena = p_zaplacena
            WHERE
                platba_id = p_platba_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
            ELSE
                o_result := '{"status": "OK", "message": "Platba byla úspěně aktualizována."}';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END manage_platba;
    
    PROCEDURE zaplat_platba(
    p_platba_id        IN platba.platba_id%TYPE,
    p_cislo_uctu       IN platba.cislo_uctu%TYPE,
    o_result           OUT CLOB
    ) IS
    BEGIN
    UPDATE platba
    SET
        cislo_uctu = p_cislo_uctu,
        zaplacena = 1
    WHERE
        platba_id = p_platba_id;

    IF SQL%ROWCOUNT = 0 THEN
        o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
    ELSE
        o_result := '{"status": "OK", "message": "Platba byla úspěšně zaplacena."}';
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END zaplat_platba;


    PROCEDURE delete_platba(
        p_platba_id        IN platba.platba_id%TYPE,
        o_result           OUT CLOB
    ) IS
    BEGIN
        DELETE FROM platba WHERE platba_id = p_platba_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Platba s daným ID nebyla nalezena."}';
        ELSE
            o_result := '{"status": "OK", "message": "Platba byla úspěně smazána."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '"}';
    END delete_platba;

END pck_platba;
/
