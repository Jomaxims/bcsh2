CREATE OR REPLACE PACKAGE pck_log_zamestnanci AS

    PROCEDURE manage_log_zamestnanci(
        p_log_id IN OUT LOG_ZAMESTNANCI.LOG_ID%TYPE,
        p_zamestnanec_id IN LOG_ZAMESTNANCI.ZAMESTNANEC_ID%TYPE,
        p_nazev_tabulky IN LOG_ZAMESTNANCI.NAZEV_TABULKY%TYPE,
        p_cas_zmeny IN LOG_ZAMESTNANCI.CAS_ZMENY%TYPE,
        p_id_instance IN LOG_ZAMESTNANCI.ID_INSTANCE%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_log_zamestnanci(
        p_log_id IN LOG_ZAMESTNANCI.LOG_ID%TYPE,
        o_result OUT CLOB
    );

END pck_log_zamestnanci;
/

CREATE OR REPLACE PACKAGE BODY pck_log_zamestnanci AS

    PROCEDURE manage_log_zamestnanci(
        p_log_id IN OUT LOG_ZAMESTNANCI.LOG_ID%TYPE,
        p_zamestnanec_id IN LOG_ZAMESTNANCI.ZAMESTNANEC_ID%TYPE,
        p_nazev_tabulky IN LOG_ZAMESTNANCI.NAZEV_TABULKY%TYPE,
        p_cas_zmeny IN LOG_ZAMESTNANCI.CAS_ZMENY%TYPE,
        p_id_instance IN LOG_ZAMESTNANCI.ID_INSTANCE%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        IF p_log_id IS NULL THEN
            INSERT INTO LOG_ZAMESTNANCI
                (ZAMESTNANEC_ID, NAZEV_TABULKY, CAS_ZMENY, ID_INSTANCE)
            VALUES
                (p_zamestnanec_id, p_nazev_tabulky, p_cas_zmeny, p_id_instance)
            RETURNING LOG_ID INTO p_log_id;

            o_result := '{ "status": "OK", "message": "Záznam logu pro zam?stnance byl úsp?šn? vytvo?en." }';
        ELSE
            UPDATE LOG_ZAMESTNANCI
            SET
                ZAMESTNANEC_ID = p_zamestnanec_id,
                NAZEV_TABULKY = p_nazev_tabulky,
                CAS_ZMENY = p_cas_zmeny,
                ID_INSTANCE = p_id_instance
            WHERE
                LOG_ID = p_log_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID záznamu logu zam?stnance nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Záznam logu zam?stnance byl úsp?šn? aktualizován." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END manage_log_zamestnanci;

    PROCEDURE delete_log_zamestnanci(
        p_log_id IN LOG_ZAMESTNANCI.LOG_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM LOG_ZAMESTNANCI WHERE LOG_ID = p_log_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: ID záznamu logu zam?stnance nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam logu zam?stnance byl úsp?šn? smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Došlo k chyb? p?i operaci: ' || SQLERRM || '" }';
    END delete_log_zamestnanci;

END pck_log_zamestnanci;
/
