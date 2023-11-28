CREATE OR REPLACE PACKAGE security AS
  FUNCTION hash_hesla(p_input VARCHAR2) RETURN VARCHAR2;
END security;
/

CREATE OR REPLACE PACKAGE BODY security AS

  FUNCTION hash_hesla(p_input VARCHAR2) RETURN VARCHAR2 IS
    l_result VARCHAR2(4000);
  BEGIN
    SELECT STANDARD_HASH(p_input, 'SHA256') INTO l_result FROM DUAL;
    RETURN l_result;
  END hash_hesla;

END security;
/

CREATE OR REPLACE FUNCTION hash_password (str IN VARCHAR2)
RETURN VARCHAR2
IS v_checksum VARCHAR2(32);
BEGIN
v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW(
sys.dbms_obfuscation_toolkit.md5(input_string => str) ) ) );
RETURN v_checksum;
EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
WHEN OTHERS THEN
RAISE;
END hash_password;
/
GRANT EXECUTE ON hash_password TO PUBLIC;

CREATE OR REPLACE PROCEDURE login(
    p_usr_name IN VARCHAR2,
    p_usr_pwd IN VARCHAR2,
    p_result OUT CLOB,
    p_usr_id OUT NUMBER
) AS
    v_id NUMBER(38); 
    v_hashed_pwd VARCHAR2(64);
BEGIN
    v_hashed_pwd := hash_password(p_usr_pwd);

    SELECT PRIHLASOVACI_UDAJE_ID INTO v_id
    FROM PRIHLASOVACI_UDAJE
    WHERE JMENO = p_usr_name
    AND HESLO = v_hashed_pwd;
    
    IF SQL%FOUND THEN
        p_usr_id := v_id;
        p_result := '{ "status": "OK", "message": "Login successful." }';
    ELSE
        p_result := '{ "status": "error", "message": "Invalid username or password." }';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := '{ "status": "error", "message": "Invalid username or password." }';
    WHEN OTHERS THEN
        p_result := '{ "status": "error", "message": "An unexpected error occurred: ' || SQLERRM || '" }';
END login;





create or replace
PACKAGE PCK_SECURITY AS

PROCEDURE edit_user(p_usr_id NUMBER,
p_usr_name VARCHAR2, p_usr_pwd VARCHAR2,
p_valid_from VARCHAR2, p_valid_till VARCHAR2,
p_result OUT CLOB);

PROCEDURE login(p_usr_name VARCHAR2, p_usr_pwd
VARCHAR2,
p_result OUT CLOB, p_usr_id OUT NUMBER);

END PCK_SECURITY;