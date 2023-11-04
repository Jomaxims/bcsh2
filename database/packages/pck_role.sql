CREATE OR REPLACE PACKAGE pck_role AS

    PROCEDURE manage_role(
        p_id_role IN OUT role.id_role%TYPE,
        p_nazev   IN role.nazev%TYPE,
        o_result  OUT CLOB
    );

    PROCEDURE delete_role(
        p_id_role IN role.id_role%TYPE,
        o_result  OUT CLOB
    );

END pck_role;
/

CREATE OR REPLACE PACKAGE BODY pck_role AS

    PROCEDURE manage_role(
        p_id_role IN OUT role.id_role%TYPE,
        p_nazev   IN role.nazev%TYPE,
        o_result  OUT CLOB
    ) IS
    BEGIN
        IF p_id_role IS NULL THEN
            INSERT INTO role (nazev)
            VALUES (p_nazev)
            RETURNING id_role INTO p_id_role;
            
            o_result := '{ "status": "OK", "message": "Role byla uspesne vytvorena." }';
        ELSE
            UPDATE role
            SET nazev = p_nazev
            WHERE id_role = p_id_role;
            
            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ROLE ID nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Role byla aktualizovana uspesne." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END manage_role;

    PROCEDURE delete_role(
        p_id_role IN role.id_role%TYPE,
        o_result  OUT CLOB
    ) IS
    BEGIN
        DELETE FROM role WHERE id_role = p_id_role;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Role nebyla nalezena." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Role byla smazana." }';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba pri operaci: ' || SQLERRM || '" }';
    END delete_role;

END pck_role;
/
