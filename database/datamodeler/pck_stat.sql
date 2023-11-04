CREATE OR REPLACE PACKAGE pck_stat AS

    PROCEDURE manage_stat(
        io_stat_id      IN  OUT stat.stat_id %TYPE,
        i_zkratka       stat.zkratka %TYPE,
        i_nazev         stat.nazev %TYPE,
        o_result        OUT VARCHAR2
    );
    
    PROCEDURE delete_stat(
        i_stat_id   IN stat.stat_id %TYPE,
        o_result    OUT VARCHAR2
    );

END pck_stat;
/


CREATE OR REPLACE PACKAGE BODY pck_stat AS

    PROCEDURE manage_stat(
        io_stat_id      IN OUT stat.stat_id%TYPE,
        i_zkratka       stat.zkratka%TYPE,
        i_nazev         stat.nazev%TYPE,
        o_result        OUT VARCHAR2
) IS
BEGIN
    IF io_stat_id IS NULL THEN
        INSERT INTO STAT(ZKRATKA, NAZEV)
        VALUES(i_zkratka, i_nazev)
        returning stat_id into io_stat_id;
        o_result := '{ "status": "OK", "message": "Stát p?idán úsp?šn?." }';
    ELSE
        UPDATE STAT
            SET ZKRATKA = i_zkratka, NAZEV = i_nazev
            WHERE STAT_ID = io_stat_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Stát aktualizován úsp?šn?." }';
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
END manage_stat;
    
   PROCEDURE delete_stat(
    i_stat_id   IN stat.stat_id %TYPE,
    o_result    OUT VARCHAR2
) IS
BEGIN
    IF i_stat_id IS NOT NULL THEN
        DELETE FROM STAT WHERE STAT_ID = i_stat_id;

        IF SQL%ROWCOUNT = 0 THEN
            o_result := '{ "status": "error", "message": "Chyba: ID státu nebylo nalezeno." }';
        ELSE
            o_result := '{ "status": "OK", "message": "Stát smazán úsp?šn?." }';
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        o_result := '{ "status": "error", "message": "Chyba p?i operaci: ' || SQLERRM || '" }';
END delete_stat;
END pck_stat;
/
