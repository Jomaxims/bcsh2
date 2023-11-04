CREATE OR REPLACE PACKAGE pck_osoba AS

    PROCEDURE manage_osoba(
        p_osoba_id  IN OUT osoba.osoba_id%TYPE,
        p_prijmeni  IN osoba.prijmeni%TYPE,
        p_jmeno     IN osoba.jmeno%TYPE,
        p_adresa_id IN osoba.adresa_id%TYPE,
        p_vek       IN osoba.vek%TYPE,
        o_result        OUT CLOB
    );

    PROCEDURE delete_osoba(
        p_osoba_id  IN osoba.osoba_id%TYPE,
        o_result        OUT CLOB
    );

END pck_osoba;
/

CREATE OR REPLACE PACKAGE BODY pck_osoba AS

    PROCEDURE manage_osoba(
        p_osoba_id  IN OUT osoba.osoba_id%TYPE,
        p_prijmeni  IN osoba.prijmeni%TYPE,
        p_jmeno     IN osoba.jmeno%TYPE,
        p_adresa_id IN osoba.adresa_id%TYPE,
        p_vek       IN osoba.vek%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_osoba_id IS NULL THEN
            INSERT INTO osoba
                  (prijmeni,
                   jmeno,
                   adresa_id,
                   vek)
      VALUES      (p_prijmeni,
                   p_jmeno,
                   p_adresa_id,
                   p_vek ) returning osoba_id into p_osoba_id;
            o_result := '{ "status": "OK", "message": "Osoba byla uspesne vytvorena." }';
        ELSE
            UPDATE osoba
      SET    prijmeni = p_prijmeni,
             jmeno = p_jmeno,
             adresa_id = p_adresa_id,
             vek = p_vek
      WHERE  osoba_id = p_osoba_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Osoba aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_osoba;

    PROCEDURE delete_osoba(
        p_osoba_id  IN osoba.osoba_id%TYPE,
        o_result        OUT CLOB
    ) IS
    BEGIN
    IF p_osoba_id IS NOT NULL THEN 
        DELETE FROM OSOBA WHERE OSOBA_ID = p_osoba_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: ID osoby nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Osoba smazána úsp?šn?." }';
        END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_osoba;

END pck_osoba;
/