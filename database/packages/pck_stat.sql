CREATE OR REPLACE PACKAGE pck_stat AS

    PROCEDURE manage_stat(
        p_stat_id      IN  OUT stat.stat_id %TYPE,
        p_zkratka       stat.zkratka %TYPE,
        p_nazev         stat.nazev %TYPE,
        o_result        OUT VARCHAR2
    );
    
    PROCEDURE delete_stat(
        p_stat_id   IN stat.stat_id %TYPE,
        o_result    OUT VARCHAR2
    );

END pck_stat;
/

CREATE OR REPLACE PACKAGE BODY pck_stat AS

    PROCEDURE manage_stat(
        p_stat_id      IN OUT stat.stat_id%TYPE,
        p_zkratka       stat.zkratka%TYPE,
        p_nazev         stat.nazev%TYPE,
        o_result        OUT VARCHAR2
    ) IS
    BEGIN
        IF p_stat_id IS NULL THEN
            INSERT INTO STAT(ZKRATKA, NAZEV)
            VALUES(p_zkratka, p_nazev)
            RETURNING stat_id INTO p_stat_id;
            o_result := '{ "status": "OK", "message": "Stát přidán úspěně." }';
        ELSE
            UPDATE STAT
            SET ZKRATKA = p_zkratka, NAZEV = p_nazev
            WHERE STAT_ID = p_stat_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Stát aktualizován úspěně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END manage_stat;

    PROCEDURE delete_stat(
        p_stat_id   IN stat.stat_id %TYPE,
        o_result    OUT VARCHAR2
    ) IS
    BEGIN
        IF p_stat_id IS NOT NULL THEN
            DELETE FROM STAT WHERE STAT_ID = p_stat_id;

            IF SQL%ROWCOUNT = 0 THEN
                o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
            ELSE
                o_result := '{ "status": "OK", "message": "Stát smazán úspěně." }';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_result := '{ "status": "error", "message": "Chyba při operaci: ' || SQLERRM || '" }';
    END delete_stat;

END pck_stat;
/

