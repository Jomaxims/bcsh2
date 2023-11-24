CREATE OR REPLACE PACKAGE pck_objednavka AS

    PROCEDURE manage_objednavka(
        p_objednavka_id IN OUT OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_pocet_osob IN OBJEDNAVKA.POCET_OSOB%TYPE,
        p_termin_id IN OBJEDNAVKA.TERMIN_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
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
        p_termin_id IN OBJEDNAVKA.TERMIN_ID%TYPE,
        p_pojisteni_id IN OBJEDNAVKA.POJISTENI_ID%TYPE DEFAULT NULL,
        p_pokoj_id IN OBJEDNAVKA.POKOJ_ID%TYPE,
        p_zakaznik_id IN OBJEDNAVKA.ZAKAZNIK_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_objednavka_id IS NULL THEN
            INSERT INTO OBJEDNAVKA
                (POCET_OSOB, TERMIN_ID, POJISTENI_ID, POKOJ_ID, ZAKAZNIK_ID)
            VALUES
                (p_pocet_osob, p_termin_id, p_pojisteni_id, p_pokoj_id, p_zakaznik_id)
            RETURNING OBJEDNAVKA_ID INTO p_objednavka_id;

            o_result := '{ "status": "OK", "message": "Nová objednávka byla úspěšně vytvořena." }';
        ELSE
            UPDATE OBJEDNAVKA
            SET
                POCET_OSOB = p_pocet_osob,
                TERMIN_ID = p_termin_id,
                POJISTENI_ID = p_pojisteni_id,
                POKOJ_ID = p_pokoj_id,
                ZAKAZNIK_ID = p_zakaznik_id
            WHERE
                OBJEDNAVKA_ID = p_objednavka_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Objednávka s daným ID nebyla nalezena." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Objednávka byla úspěšně aktualizována." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
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
            o_result := '{ "status": "OK", "message": "Objednávka byla úspěšně smazána." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při zpracování: ' || SQLERRM || '" }';
    END delete_objednavka;

END pck_objednavka;
