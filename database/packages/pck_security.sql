CREATE OR REPLACE PACKAGE pck_security AS
  FUNCTION hash_hesla(str IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION login(p_usr_name IN VARCHAR2, p_usr_pwd IN VARCHAR2) RETURN SYS_REFCURSOR;
END pck_security;
/


CREATE OR REPLACE PACKAGE BODY pck_security AS

    FUNCTION hash_hesla(str IN VARCHAR2) RETURN VARCHAR2 IS
        v_checksum VARCHAR2(32);
    BEGIN
        v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW(
            sys.dbms_obfuscation_toolkit.md5(input_string => str) 
        ) ) );
        RETURN v_checksum;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;
    END hash_hesla;

    FUNCTION login(p_usr_name IN VARCHAR2, p_usr_pwd IN VARCHAR2) RETURN SYS_REFCURSOR IS
        v_id PRIHLASOVACI_UDAJE.PRIHLASOVACI_UDAJE_ID%TYPE; 
        v_hashed_pwd VARCHAR2(64);
        v_role_id ZAMESTNANEC.ROLE_ID%TYPE;
        v_zamestnanec_id ZAMESTNANEC.ZAMESTNANEC_ID%TYPE;
        v_cursor SYS_REFCURSOR;
        v_error_message VARCHAR2(255);
    BEGIN
    v_hashed_pwd := hash_hesla(p_usr_pwd);

    SELECT PRIHLASOVACI_UDAJE_ID INTO v_id
    FROM PRIHLASOVACI_UDAJE
    WHERE JMENO = p_usr_name
    AND HESLO = v_hashed_pwd;

    -- zakaznik
    BEGIN
        SELECT ZAKAZNIK_ID INTO v_id
        FROM ZAKAZNIK
        WHERE PRIHLASOVACI_UDAJE_ID = v_id;

        OPEN v_cursor FOR
        SELECT ZAKAZNIK_ID AS uzivatel_id, 'zakaznik' AS role
        FROM ZAKAZNIK
        WHERE ZAKAZNIK_ID = v_id;
        RETURN v_cursor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; 
    END;

    -- zaměstnanec
    BEGIN
        SELECT z.ROLE_ID, z.ZAMESTNANEC_ID INTO v_role_id, v_zamestnanec_id
        FROM ZAMESTNANEC z
        WHERE z.PRIHLASOVACI_UDAJE_ID = v_id;

        OPEN v_cursor FOR
        SELECT ZAMESTNANEC_ID AS uzivatel_id, (SELECT r.NAZEV FROM ROLE r WHERE r.ROLE_ID = v_role_id) AS role
        FROM ZAMESTNANEC
        WHERE ZAMESTNANEC_ID = v_zamestnanec_id;
        RETURN v_cursor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            OPEN v_cursor FOR
            SELECT NULL AS uzivatel_id, 'Nesprávné jméno nebo heslo' AS role
            FROM DUAL;
            RETURN v_cursor;
    END;
EXCEPTION
        WHEN OTHERS THEN
            v_error_message := 'Neočekávaný error se vyskytl: ' || SQLERRM;
            OPEN v_cursor FOR
            SELECT NULL AS uzivatel_id, v_error_message AS role
            FROM DUAL;
            RETURN v_cursor;
    END login;

END pck_security;
/




GRANT EXECUTE ON hash_hesla TO PUBLIC;