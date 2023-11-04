CREATE OR REPLACE PACKAGE pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id IN OUT PLATBA.PLATBA_ID%TYPE,
        p_castka IN PLATBA.CASTKA%TYPE,
        p_datum_splatnosti IN PLATBA.DATUM_SPLATNOSTI%TYPE,
        p_zaplacena IN PLATBA.ZAPLACENA%TYPE,
        p_cislo_uctu IN PLATBA.CISLO_UCTU%TYPE,
        p_objednavka_id IN PLATBA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_platba(
        p_platba_id IN PLATBA.PLATBA_ID%TYPE,
        o_result OUT CLOB
    );

END pck_platba;
/

CREATE OR REPLACE PACKAGE BODY pck_platba AS

    PROCEDURE manage_platba(
        p_platba_id IN OUT PLATBA.PLATBA_ID%TYPE,
        p_castka IN PLATBA.CASTKA%TYPE,
        p_datum_splatnosti IN PLATBA.DATUM_SPLATNOSTI%TYPE,
        p_zaplacena IN PLATBA.ZAPLACENA%TYPE,
        p_cislo_uctu IN PLATBA.CISLO_UCTU%TYPE,
        p_objednavka_id IN PLATBA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_platba_id IS NULL THEN
            INSERT INTO PLATBA
                (CASTKA, DATUM_SPLATNOSTI, ZAPLACENA, CISLO_UCTU, OBJEDNAVKA_ID)
            VALUES
                (p_castka, p_datum_splatnosti, p_zaplacena, p_cislo_uctu, p_objednavka_id)
            RETURNING PLATBA_ID INTO p_platba_id;

            o_result := '{ "status": "OK", "message": "Nov� platba byla �sp?�n? vytvo?ena." }';
        ELSE
            UPDATE PLATBA
            SET
                CASTKA = p_castka,
                DATUM_SPLATNOSTI = p_datum_splatnosti,
                ZAPLACENA = p_zaplacena,
                CISLO_UCTU = p_cislo_uctu,
                OBJEDNAVKA_ID = p_objednavka_id
            WHERE
                PLATBA_ID = p_platba_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Platba s dan�m ID nebyla nalezena." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Platba byla �sp?�n? aktualizov�na." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || SQLERRM || '" }';
    END manage_platba;

    PROCEDURE delete_platba(
        p_platba_id IN PLATBA.PLATBA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM PLATBA WHERE PLATBA_ID = p_platba_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Platba s dan�m ID nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Platba byla �sp?�n? smaz�na." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Do�lo k chyb? p?i zpracov�n�: ' || SQLERRM || '" }';
    END delete_platba;

END pck_platba;
/
