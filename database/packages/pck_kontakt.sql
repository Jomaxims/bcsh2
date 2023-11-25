CREATE OR REPLACE PACKAGE pck_kontakt AS

    PROCEDURE manage_kontakt(
        p_telefon       IN kontakt.telefon%TYPE,
        p_kontakt_id    IN OUT kontakt.kontakt_id%TYPE,
        p_email         IN kontakt.email%TYPE,
        o_result        OUT CLOB
    );

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result     OUT CLOB
    );

END pck_kontakt;
/

CREATE OR REPLACE PACKAGE BODY pck_kontakt AS

    PROCEDURE manage_kontakt(
        p_telefon       IN kontakt.telefon%TYPE,
        p_kontakt_id    IN OUT kontakt.kontakt_id%TYPE,
        p_email         IN kontakt.email%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NULL THEN
            INSERT INTO kontakt
                 (telefon,
                 email)
            VALUES
                (p_telefon,
                 p_email)
            RETURNING kontakt_id INTO p_kontakt_id;
            o_result := '{ "status": "OK", "message": "Kontakt byl uspesne vytvoren." }';
        ELSE
            UPDATE kontakt
            SET    telefon = p_telefon,
                   email = p_email
            WHERE  kontakt_id = p_kontakt_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID kontakt nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt aktualizován úspěšně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_kontakt;

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result     OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NOT NULL THEN 
            DELETE FROM kontakt WHERE kontakt_id = p_kontakt_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt smazán úspěšně." }';
            END IF;
        ELSE
            o_result := '{ "status": "error", "message": "Chyba: Nebylo zadáno žádné ID kontaktu pro smazání." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_kontakt;

END pck_kontakt;
/
