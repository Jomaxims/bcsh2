CREATE OR REPLACE PACKAGE pck_osoba_objednavka AS

    PROCEDURE insert_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE update_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_old_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_new_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

    PROCEDURE delete_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    );

END pck_osoba_objednavka;
/

CREATE OR REPLACE PACKAGE BODY pck_osoba_objednavka AS

    PROCEDURE insert_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        INSERT INTO OSOBA_OBJEDNAVKA (OSOBA_ID, OBJEDNAVKA_ID)
        VALUES (p_osoba_id, p_objednavka_id);

        o_result := '{ "status": "OK", "message": "Záznam byl úsp?šn? vytvo?en." }';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END insert_osoba_objednavka;

    PROCEDURE update_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_old_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        p_new_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        UPDATE OSOBA_OBJEDNAVKA
        SET OBJEDNAVKA_ID = p_new_objednavka_id
        WHERE OSOBA_ID = p_osoba_id
        AND OBJEDNAVKA_ID = p_old_objednavka_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Záznam nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam byl úsp?šn? aktualizován." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END update_osoba_objednavka;

    PROCEDURE delete_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OSOBA_OBJEDNAVKA WHERE OSOBA_ID = p_osoba_id AND OBJEDNAVKA_ID = p_objednavka_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: Záznam nebyl nalezen." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Záznam byl úsp?šn? smazán." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
    END delete_osoba_objednavka;

END pck_osoba_objednavka;
/
