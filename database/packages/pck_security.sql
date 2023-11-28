CREATE OR REPLACE PACKAGE pck_security AS
  FUNCTION hash_hesla(str IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION login(p_usr_name IN VARCHAR2, p_usr_pwd IN VARCHAR2) RETURN CLOB;
END pck_security;
/

CREATE OR REPLACE PACKAGE BODY pck_security AS

    FUNCTION hash_hesla(str IN VARCHAR2)
    RETURN VARCHAR2 IS
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

    FUNCTION login(p_usr_name IN VARCHAR2, p_usr_pwd IN VARCHAR2)
    RETURN CLOB AS
        v_id NUMBER(38); 
        v_hashed_pwd VARCHAR2(64);
        v_role_id NUMBER(38);
        v_role_name VARCHAR2(50);
        v_zamestnanec_id NUMBER(38);
        p_result CLOB;
    BEGIN
        v_hashed_pwd := hash_hesla(p_usr_pwd);

        SELECT PRIHLASOVACI_UDAJE_ID INTO v_id
        FROM PRIHLASOVACI_UDAJE
        WHERE JMENO = p_usr_name
        AND HESLO = v_hashed_pwd;

        -- zákazník
        BEGIN
            SELECT ZAKAZNIK_ID INTO v_id
            FROM ZAKAZNIK
            WHERE PRIHLASOVACI_UDAJE_ID = v_id;

            p_result := '{ "status": "OK", "message": "Login úspěšný.", "uživatel": ' || v_id || ', "role": "zakaznik" }';
            RETURN p_result;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        -- zaměstnanec
        BEGIN
            SELECT z.ROLE_ID, z.ZAMESTNANEC_ID INTO v_role_id, v_zamestnanec_id
        FROM ZAMESTNANEC z
        WHERE z.PRIHLASOVACI_UDAJE_ID = v_id;

        SELECT r.NAZEV INTO v_role_name
        FROM ROLE r
        WHERE r.ROLE_ID = v_role_id;

            p_result := '{ "status": "OK", "message": "Login úspěšný.", "uživatel": ' || v_zamestnanec_id || ', "role": "' || v_role_name || '" }';
            RETURN p_result;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_result := '{ "status": "error", "message": "Nesprávné jméno nebo heslo." }';
                RETURN p_result;
        END;
    EXCEPTION
        WHEN OTHERS THEN
            p_result := '{ "status": "error", "message": "Neočekávaný error se vyskytl: ' || SQLERRM || '" }';
            RETURN p_result;
    END login;

END pck_security;
/




GRANT EXECUTE ON hash_hesla TO PUBLIC;