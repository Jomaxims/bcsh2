CREATE OR REPLACE PACKAGE pck_objednavka AS

    PROCEDURE manage_objednavka(
        p_objednavka_id IN OUT OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_pocet_osob IN OBJEDNAVKA.POCET_OSOB%TYPE,
        p_terminy_id IN OBJEDNAVKA.TERMINY_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
        p_zajezd_id IN OBJEDNAVKA.ZAJEZD_ID%TYPE,
        p_doprava_id IN OBJEDNAVKA.DOPRAVA_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_objednavka(
        p_objednavka_id IN OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

END pck_objednavka;
/

CREATE OR REPLACE PACKAGE BODY pck_objednavka AS

    PROCEDURE manage_objednavka(
        p_objednavka_id IN OUT OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_pocet_osob IN OBJEDNAVKA.POCET_OSOB%TYPE,
        p_terminy_id IN OBJEDNAVKA.TERMINY_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
        p_zajezd_id IN OBJEDNAVKA.ZAJEZD_ID%TYPE,
        p_doprava_id IN OBJEDNAVKA.DOPRAVA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_objednavka_id IS NULL THEN
            INSERT INTO OBJEDNAVKA
                (POCET_OSOB, TERMINY_ID, POJISTENI_ID, POKOJ_ID, ZAKAZNIK_ID, ZAJEZD_ID, DOPRAVA_ID)
            VALUES
                (p_pocet_osob, p_terminy_id, p_pojisteni_id, p_pokoj_id, p_zakaznik_id, p_zajezd_id, p_doprava_id)
            RETURNING OBJEDNAVKA_ID INTO p_objednavka_id;

            o_result := '{ "status": "OK", "message": "Nová objednávka byla úsp?šn? vytvo?ena." }';
        ELSE
            UPDATE OBJEDNAVKA
            SET
                POCET_OSOB = p_pocet_osob,
                TERMINY_ID = p_terminy_id,
                POJISTENI_ID = p_pojisteni_id,
                POKOJ_ID = p_pokoj_id,
                ZAKAZNIK_ID = p_zakaznik_id,
                ZAJEZD_ID = p_zajezd_id,
                DOPRAVA_ID = p_doprava_id
            WHERE
                OBJEDNAVKA_ID = p_objednavka_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Objednávka s daným ID nebyla nalezena." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Objednávka byla úsp?šn? aktualizována." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END manage_objednavka;

    PROCEDURE delete_objednavka(
        p_objednavka_id IN OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OBJEDNAVKA WHERE OBJEDNAVKA_ID = p_objednavka_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Objednávka s daným ID nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Objednávka byla úsp?šn? smazána." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i zpracování: ' || SQLERRM || '" }';
    END delete_objednavka;

END pck_objednavka;
