CREATE OR REPLACE PACKAGE pck_kontakt AS

    PROCEDURE manage_kontakt(
    p_osoba_id   IN kontakt.osoba_id%TYPE,
    p_telefon    IN kontakt.telefon%TYPE,
    p_kontakt_id IN OUT kontakt.kontakt_id%TYPE,
    p_email      IN kontakt.email%TYPE,
    o_result        OUT CLOB
    );

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result        OUT CLOB
    );

END pck_kontakt;
/

CREATE OR REPLACE PACKAGE BODY pck_kontakt AS
 PROCEDURE manage_kontakt(
    p_osoba_id   IN kontakt.osoba_id%TYPE,
    p_telefon    IN kontakt.telefon%TYPE,
    p_kontakt_id IN OUT kontakt.kontakt_id%TYPE,
    p_email      IN kontakt.email%TYPE,
    o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NULL THEN
            INSERT INTO kontakt
                  (osoba_id,
                   telefon,
                   email)
      VALUES      ( p_osoba_id,
                   p_telefon,
                   p_email )
                returning kontakt_id into p_kontakt_id;
                o_result := '{ "status": "OK", "message": "Kontakt byl uspesne vytvoren." }';
        ELSE
             UPDATE kontakt
      SET    osoba_id = p_osoba_id,
             telefon = p_telefon,
             email = p_email
      WHERE  kontakt_id = p_kontakt_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID kontakt nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt aktualizován uspesne?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_kontakt;

    PROCEDURE delete_kontakt(
        p_kontakt_id IN kontakt.kontakt_id%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_kontakt_id IS NOT NULL THEN 
            DELETE FROM KONTAKT WHERE KONTAKT_ID =  p_kontakt_id;
        
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Kontakt smazán úspešne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_kontakt;

END pck_kontakt;
/
