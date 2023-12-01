CREATE OR REPLACE PACKAGE pck_zamestnanec AS

    PROCEDURE manage_zamestnanec(
        p_zamestnanec_id IN OUT zamestnanec.zamestnanec_id%TYPE,
        p_role_id       IN zamestnanec.role_id%TYPE,
        p_prihlasovaci_udaje_id    IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        p_prijmeni  IN zamestnanec.prijmeni%TYPE,
        p_jmeno     IN zamestnanec.jmeno%TYPE,
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
        p_role_id       IN zamestnanec.role_id%TYPE,
        p_prihlasovaci_udaje_id    IN zakaznik.PRIHLASOVACI_UDAJE_ID%TYPE,
        p_nadrizeny_id   IN zamestnanec.nadrizeny_id%TYPE,
        p_prijmeni  IN zamestnanec.prijmeni%TYPE,
        p_jmeno     IN zamestnanec.jmeno%TYPE,
        o_result         OUT CLOB
    ) IS
    BEGIN
        IF p_zamestnanec_id IS NULL THEN
            INSERT INTO zamestnanec (role_id, PRIHLASOVACI_UDAJE_ID, nadrizeny_id, prijmeni, jmeno)
            VALUES (p_role_id, p_prihlasovaci_udaje_id, p_nadrizeny_id, p_prijmeni, p_jmeno)
            RETURNING zamestnanec_id INTO p_zamestnanec_id;
            
            o_result := '{ "status": "OK", "message": "Zamestnanec byl uspesne vytvoren." }';
        ELSE
            UPDATE zamestnanec
            SET role_id = p_role_id,
                PRIHLASOVACI_UDAJE_ID = p_prihlasovaci_udaje_id,
                nadrizeny_id = p_nadrizeny_id,
                prijmeni = p_prijmeni,
                jmeno = p_jmeno
            WHERE zamestnanec_id = p_zamestnanec_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ZAMESTNANEC ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Zamestnanec aktualizovan �sp?�n?." }';
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
        UPDATE zamestnanec SET nadrizeny_id = NULL WHERE nadrizeny_id = p_zamestnanec_id;
        
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
