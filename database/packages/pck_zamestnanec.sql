CREATE OR REPLACE PACKAGE pck_zamestnanec AS

    PROCEDURE manage_zamestnanec(
        p_zamestnanec_id IN OUT zamestnanec.zamestnanec_id%TYPE,
        p_id_role        IN zamestnanec.id_role%TYPE,
        p_udaje_id       IN zamestnanec.udaje_id%TYPE,
        p_osoba_id       IN zamestnanec.osoba_id%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        o_result         OUT CLOB
    );

    PROCEDURE delete_zamestnanec(
        p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE,
        o_result         OUT CLOB
    );

END pck_zamestnanec;
/

CREATE OR REPLACE PACKAGE BODY pck_zamestnanec AS

    PROCEDURE manage_zamestnanec(
        p_zamestnanec_id IN OUT zamestnanec.zamestnanec_id%TYPE,
        p_id_role        IN zamestnanec.id_role%TYPE,
        p_udaje_id       IN zamestnanec.udaje_id%TYPE,
        p_osoba_id       IN zamestnanec.osoba_id%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        o_result         OUT CLOB
    ) IS
    BEGIN
        IF p_zamestnanec_id IS NULL THEN
            INSERT INTO zamestnanec (id_role, udaje_id, osoba_id, nadrizeny_id)
            VALUES (p_id_role, p_udaje_id, p_osoba_id, p_nadrizeny_id)
            RETURNING zamestnanec_id INTO p_zamestnanec_id;
            
            o_result := '{ "status": "OK", "message": "Zamestnanec byl uspesne vytvoren." }';
        ELSE
            UPDATE zamestnanec
            SET id_role = p_id_role,
                udaje_id = p_udaje_id,
                osoba_id = p_osoba_id,
                nadrizeny_id = p_nadrizeny_id
            WHERE zamestnanec_id = p_zamestnanec_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ZAMESTNANEC ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zamestnanec aktualizovan úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_zamestnanec;

    PROCEDURE delete_zamestnanec(
        p_zamestnanec_id IN zamestnanec.zamestnanec_id%TYPE,
        o_result         OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zamestnanec WHERE zamestnanec_id = p_zamestnanec_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Zamestnanec nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zamestnanec byl smazan." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_zamestnanec;

END pck_zamestnanec;
/
