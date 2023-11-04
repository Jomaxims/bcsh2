CREATE OR REPLACE PACKAGE pck_log_zakaznici AS

    PROCEDURE manage_log_zakaznici(
        p_log_id IN OUT LOG_ZAKAZNICI.LOG_ID%TYPE,
        p_nazev_tabulky IN LOG_ZAKAZNICI.NAZEV_TABULKY%TYPE,
        p_cas_zmeny IN LOG_ZAKAZNICI.CAS_ZMENY%TYPE,
        p_id_instance IN LOG_ZAKAZNICI.ID_INSTANCE%TYPE,
        p_zakaznik_id IN LOG_ZAKAZNICI.ZAKAZNIK_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_log_zakaznici(
        p_log_id IN LOG_ZAKAZNICI.LOG_ID%TYPE,
        o_result OUT CLOB
    );

END pck_log_zakaznici;
/

CREATE OR REPLACE PACKAGE BODY pck_log_zakaznici AS

    PROCEDURE manage_log_zakaznici(
        p_log_id IN OUT LOG_ZAKAZNICI.LOG_ID%TYPE,
        p_nazev_tabulky IN LOG_ZAKAZNICI.NAZEV_TABULKY%TYPE,
        p_cas_zmeny IN LOG_ZAKAZNICI.CAS_ZMENY%TYPE,
        p_id_instance IN LOG_ZAKAZNICI.ID_INSTANCE%TYPE,
        p_zakaznik_id IN LOG_ZAKAZNICI.ZAKAZNIK_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_log_id IS NULL THEN
            INSERT INTO LOG_ZAKAZNICI
                (NAZEV_TABULKY, CAS_ZMENY, ID_INSTANCE, ZAKAZNIK_ID)
            VALUES
                (p_nazev_tabulky, p_cas_zmeny, p_id_instance, p_zakaznik_id)
            RETURNING LOG_ID INTO p_log_id;

            o_result := '{ "status": "OK", "message": "Záznam logu pro zákazníka byl úsp?šn? vytvo?en." }';
        ELSE
            UPDATE LOG_ZAKAZNICI
            SET
                NAZEV_TABULKY = p_nazev_tabulky,
                CAS_ZMENY = p_cas_zmeny,
                ID_INSTANCE = p_id_instance,
                ZAKAZNIK_ID = p_zakaznik_id
            WHERE
                LOG_ID = p_log_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID záznamu logu zákazníka nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Záznam logu zákazníka byl úsp?šn? aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END manage_log_zakaznici;

    PROCEDURE delete_log_zakaznici(
        p_log_id IN LOG_ZAKAZNICI.LOG_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM LOG_ZAKAZNICI WHERE LOG_ID = p_log_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: ID záznamu logu zákazníka nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam logu zákazníka byl úsp?šn? smazán." }';
        END IF;
    EXCEPTION
       WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END delete_log_zakaznici;

END pck_log_zakaznici;
/
