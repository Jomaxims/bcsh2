DECLARE
    v_role_id role.role_id%TYPE;
    v_result VARCHAR2(100);
BEGIN
v_role_id := NULL;
pck_role.manage_role(v_role_id, 'admin', v_result);
DBMS_OUTPUT.PUT_LINE(v_result);
v_role_id := NULL;
pck_role.manage_role(v_role_id, 'zamestnanec', v_result);
DBMS_OUTPUT.PUT_LINE(v_result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;