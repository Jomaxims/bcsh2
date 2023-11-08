CREATE OR REPLACE PACKAGE pck_log AS

    PROCEDURE manage_log(
        p_log_id   IN OUT LOG_TABEL.log_id%TYPE,
        p_tabulka  IN LOG_TABEL.tabulka%TYPE,
        p_operace  IN LOG_TABEL.operace%TYPE,
        p_cas_zmeny IN LOG_TABEL.cas_zmeny%TYPE,
        p_uzivatel  IN LOG_TABEL.uzivatel%TYPE,
        p_pred     IN LOG_TABEL.pred%TYPE,
        p_po       IN LOG_TABEL.po%TYPE,
        o_result   OUT CLOB
    );

    PROCEDURE delete_log(
        p_log_id   IN LOG_TABEL.log_id%TYPE,
        o_result   OUT CLOB
    );

END pck_log;
/

CREATE OR REPLACE PACKAGE BODY pck_log AS

    PROCEDURE manage_log(
        p_log_id   IN OUT LOG_TABEL.log_id%TYPE,
        p_tabulka  IN LOG_TABEL.tabulka%TYPE,
        p_operace  IN LOG_TABEL.operace%TYPE,
        p_cas_zmeny IN LOG_TABEL.cas_zmeny%TYPE,
        p_uzivatel  IN LOG_TABEL.uzivatel%TYPE,
        p_pred     IN LOG_TABEL.pred%TYPE,
        p_po       IN LOG_TABEL.po%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        IF p_log_id IS NULL THEN
            INSERT INTO LOG_TABEL (tabulka, operace, cas_zmeny, uzivatel, pred, po)
            VALUES (p_tabulka, p_operace, p_cas_zmeny, p_uzivatel, p_pred, p_po)
            RETURNING log_id INTO p_log_id;
            
            o_result := '{ "status": "OK", "message": "Log zaznam byl uspesne vytvoren." }';
        ELSE
            UPDATE LOG_TABEL
            SET tabulka = p_tabulka,
                operace = p_operace,
                cas_zmeny = p_cas_zmeny,
                uzivatel = p_uzivatel,
                pred = p_pred,
                po = p_po
            WHERE log_id = p_log_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: LOG_ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Log zaznam byl uspesne aktualizovan." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_log;

    PROCEDURE delete_log(
        p_log_id   IN LOG_TABEL.log_id%TYPE,
        o_result   OUT CLOB
    ) IS
    BEGIN
        DELETE FROM LOG_TABEL WHERE log_id = p_log_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Log nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": Log byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_log;

END pck_log;
/
