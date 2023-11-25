CREATE OR REPLACE PACKAGE pck_zakaznik AS

    PROCEDURE manage_zakaznik(
        p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
        p_prihlasovaci_udaje_id IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_osoba_id IN zakaznik.osoba_id%TYPE,
        p_adresa_id IN zakaznik.adresa_id%TYPE,
        p_kontakt_id IN zakaznik.kontakt_id%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result OUT CLOB
    );

END pck_zakaznik;
/

CREATE OR REPLACE PACKAGE BODY pck_zakaznik AS

    PROCEDURE manage_zakaznik(
        p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
        p_prihlasovaci_udaje_id IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_osoba_id IN zakaznik.osoba_id%TYPE,
        p_adresa_id IN zakaznik.adresa_id%TYPE,
        p_kontakt_id IN zakaznik.kontakt_id%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_zakaznik_id IS NULL THEN
            INSERT INTO zakaznik (
                prihlasovaci_udaje_id,
                osoba_id,
                adresa_id,
                kontakt_id
            ) VALUES (
                p_prihlasovaci_udaje_id,
                p_osoba_id,
                p_adresa_id,
                p_kontakt_id
            ) RETURNING zakaznik_id INTO p_zakaznik_id;

            o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně vytvořen." }';
        ELSE
            UPDATE zakaznik
            SET
                prihlasovaci_udaje_id = p_prihlasovaci_udaje_id,
                osoba_id = p_osoba_id,
                adresa_id = p_adresa_id,
                kontakt_id = p_kontakt_id
            WHERE
                zakaznik_id = p_zakaznik_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Zákazník s daným ID nebyl nalezen." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při operaci: ' || SQLERRM || '" }';
    END manage_zakaznik;

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zakaznik WHERE zakaznik_id = p_zakaznik_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Zákazník s daným ID nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zákazník byl úspěšně smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chybě při operaci: ' || SQLERRM || '" }';
    END delete_zakaznik;

END pck_zakaznik;
/
