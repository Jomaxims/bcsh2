CREATE OR REPLACE PACKAGE pck_adresa AS

    PROCEDURE manage_adresa(
        p_adresa_id     IN OUT ADRESA.ADRESA_ID%type,
        p_psc           IN adresa.psc%TYPE,
        p_stat_id       IN adresa.stat_id%TYPE,
        p_ulice         IN adresa.ulice%TYPE,
        p_mesto         IN adresa.mesto%TYPE,
        p_cislo_popisne IN adresa.cislo_popisne%TYPE,
        p_poznamka      IN adresa.poznamka%TYPE DEFAULT NULL,
        o_result        OUT CLOB
    );

    PROCEDURE delete_adresa(
        p_adresa_id     IN ADRESA.ADRESA_ID%type,
        o_result        OUT CLOB
    );

END pck_adresa;
/

CREATE OR REPLACE PACKAGE BODY pck_adresa AS

    PROCEDURE manage_adresa(
        p_adresa_id     IN OUT ADRESA.ADRESA_ID%type,
        p_psc           IN adresa.psc%TYPE,
        p_stat_id       IN adresa.stat_id%TYPE,
        p_ulice         IN adresa.ulice%TYPE,
        p_mesto         IN adresa.mesto%TYPE,
        p_cislo_popisne IN adresa.cislo_popisne%TYPE,
        p_poznamka      IN adresa.poznamka%TYPE DEFAULT NULL,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_adresa_id IS NULL THEN
            INSERT INTO ADRESA(ULICE, CISLO_POPISNE, MESTO, PSC, POZNAMKA, STAT_ID)
                VALUES(p_ulice, p_cislo_popisne, p_mesto, p_psc, p_poznamka, p_stat_id)
                returning adresa_id into p_adresa_id;
                o_result := '{ "status": "OK", "message": "Adresa byla uspesne vytvorena." }';
        ELSE
             UPDATE ADRESA
                SET ULICE = p_ulice,
                    CISLO_POPISNE = p_cislo_popisne,
                    MESTO = p_mesto,
                    PSC = p_psc,
                    POZNAMKA = p_poznamka,
                    STAT_ID = p_stat_id
                WHERE ADRESA_ID = p_adresa_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa aktualizován úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END manage_adresa;

    PROCEDURE delete_adresa(
         p_adresa_id     IN ADRESA.ADRESA_ID%type,
        o_result        OUT CLOB
    ) IS
    BEGIN
        IF p_adresa_id IS NOT NULL THEN 
            DELETE FROM ADRESA WHERE ADRESA_ID =  p_adresa_id;
        
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID adresy nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Adresa smazána úsp?šn?." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_adresa;

END pck_adresa;
/