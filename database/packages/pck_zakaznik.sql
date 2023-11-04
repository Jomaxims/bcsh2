CREATE OR REPLACE PACKAGE pck_zakaznik AS

    PROCEDURE manage_zakaznik(
    p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
    p_udaje_id    IN zakaznik.udaje_id%TYPE,
    p_osoba_id    IN zakaznik.osoba_id%TYPE,
    o_result      OUT CLOB
    );

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result      OUT CLOB
    );

END pck_zakaznik;
/

CREATE OR REPLACE PACKAGE BODY pck_zakaznik AS

    PROCEDURE manage_zakaznik(
    p_zakaznik_id IN OUT zakaznik.zakaznik_id%TYPE,
    p_udaje_id    IN zakaznik.udaje_id%TYPE,
    p_osoba_id    IN zakaznik.osoba_id%TYPE,
    o_result      OUT CLOB
    ) IS
    BEGIN
        IF p_zakaznik_id IS NULL THEN
            
            INSERT INTO zakaznik
                  (udaje_id,
                   osoba_id)
            VALUES
                  (p_udaje_id,
                   p_osoba_id);
                   
            o_result := '{ "status": "OK", "message": "Zakaznik byl uspesne vytvoren." }';
        ELSE
             UPDATE zakaznik
             SET    udaje_id = p_udaje_id,
                    osoba_id = p_osoba_id
             WHERE  zakaznik_id = p_zakaznik_id;
                
             IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: Zakaznik ID nebylo nalezeno." }';
             ELSE
                o_result := '{ "status": "OK", "message": "Zakaznik aktualizov�n uspesne." }';
             END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_zakaznik;

    PROCEDURE delete_zakaznik(
        p_zakaznik_id IN zakaznik.zakaznik_id%TYPE,
        o_result      OUT CLOB
    ) IS
    BEGIN
        DELETE FROM zakaznik WHERE zakaznik_id = p_zakaznik_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Zakaznik ID nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Zakaznik smaz�n �spe�ne." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_zakaznik;

END pck_zakaznik;
/
