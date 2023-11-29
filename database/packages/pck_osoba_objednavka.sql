CREATE OR REPLACE PACKAGE pck_osoba_objednavka AS

    PROCEDURE manage_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
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

    PROCEDURE manage_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        INSERT INTO OSOBA_OBJEDNAVKA (OSOBA_ID, OBJEDNAVKA_ID)
        VALUES (p_osoba_id, p_objednavka_id);

        o_result := '{"status": "OK", "message": "Záznam byl úspěně vytvořen."}';
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Chyba při operaci: ' || SQLERRM || '"}';
    END manage_objednavka;

    PROCEDURE delete_osoba_objednavka(
        p_osoba_id IN OSOBA_OBJEDNAVKA.OSOBA_ID%TYPE,
        p_objednavka_id IN OSOBA_OBJEDNAVKA.OBJEDNAVKA_ID%TYPE,
        o_result OUT CLOB
    ) IS
    BEGIN
        DELETE FROM OSOBA_OBJEDNAVKA WHERE OSOBA_ID = p_osoba_id AND OBJEDNAVKA_ID = p_objednavka_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{"status": "error", "message": "Chyba: Záznam nebyl nalezen."}';
        ELSE
            o_result := '{"status": "OK", "message": "Záznam byl úspěně smazán."}';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{"status": "error", "message": "Chyba při operaci: ' || SQLERRM || '"}';
    END delete_osoba_objednavka;

END pck_osoba_objednavka;
/
