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
