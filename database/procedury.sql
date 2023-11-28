SET SERVEROUTPUT ON;


DECLARE
    v_stat_id  NUMBER;--jenom NUMBER pro insert
    v_result   VARCHAR2(100);
BEGIN
    stat_package.manage_stat(
        io_stat_id   => v_stat_id,
        i_zkratka   => 'PL',
        i_nazev     => 'Polsko',
        o_result    => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_stat_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


DECLARE
 v_stat_id  NUMBER:= 5;
 v_result VARCHAR2(100);
BEGIN
    stat_package.delete_stat(
        i_stat_id => v_stat_id,
        o_result  => v_result
    );

    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    l_prihlasovaci_udaje_id prihlasovaci_udaje.PRIHLASOVACI_UDAJE_ID%TYPE := NULL; -- NULL for new entry
    l_jmeno prihlasovaci_udaje.jmeno%TYPE := 'PEPA'; -- Example username
    l_heslo prihlasovaci_udaje.heslo%TYPE := 'pepa'; -- Example password
    l_result CLOB;
BEGIN
    -- Call the procedure to add new user login data
    pck_prihlasovaci_udaje.manage_prihlasovaci_udaje(
        l_prihlasovaci_udaje_id,
        l_jmeno,
        l_heslo,
        l_result
    );

    -- Output the result of the procedure call
    DBMS_OUTPUT.PUT_LINE(l_result);

    -- Optionally, output the new user ID if needed
    DBMS_OUTPUT.PUT_LINE('New User ID: ' || TO_CHAR(l_prihlasovaci_udaje_id));
END;
/

DECLARE
    result CLOB;
BEGIN
    result := pck_security.login('PEPA', 'pepa');
    DBMS_OUTPUT.PUT_LINE(result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;







DECLARE
    v_result CLOB;
    v_adresa_id INTEGER;
BEGIN
    pck_adresa.manage_adresa(
        p_adresa_id =>  v_adresa_id,
        p_ulice => 'Na Prikope',
        p_cislo_popisne => '1234',
        p_mesto => 'Liberec',
        p_psc => '11000',
        p_poznamka => 'Centrum Liberce',
        p_stat_id => 1,
        o_result => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_adresa_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    v_result CLOB;
    v_adresa_id INTEGER;
BEGIN
    pck_adresa.delete_adresa(
        p_adresa_id =>  1,
        o_result => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_adresa_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
  v_result CLOB;
  v_osoba_id INTEGER;
BEGIN

  pck_osoba.manage_osoba(
    p_osoba_id => v_osoba_id,
    p_jmeno => 'Pepa',
    p_prijmeni => 'Zdepa',
    p_vek => 40,
    p_adresa_id => 2,
    o_result => v_result
  );DBMS_OUTPUT.PUT_LINE('ID: ' || v_osoba_id);
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    v_kontakt_id  NUMBER;--jenom NUMBER pro insert
    v_result   CLOB;
BEGIN
    pck_kontakt.manage_kontakt(
        p_kontakt_id   => v_kontakt_id,
        p_osoba_id   => 1,
        p_telefon     => '839930234',
        p_email => 'pepa.com',
        o_result    => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_kontakt_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
 v_kontakt_id  NUMBER:= 1;
 v_result CLOB;
BEGIN
    pck_kontakt.delete_kontakt(
        p_kontakt_id => v_kontakt_id,
        o_result  => v_result
    );

    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


DECLARE
    v_stat_id  NUMBER;--jenom NUMBER pro insert
    v_result   VARCHAR2(100);
BEGIN
    pck_role.manage_role(
        p_id_role   => v_stat_id,
        p_nazev   => 'ADMIN',
        o_result    => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_stat_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    v_id  NUMBER;--jenom NUMBER pro insert
    v_result   VARCHAR2(100);
BEGIN
    pck_prihlasovaci_udaje.manage_prihlasovaci_udaje(
        p_prihlasovaci_udaje_id   => v_id,
        p_jmeno   => 'ADMIN',
        p_heslo  =>  'pepa',
        o_result    => v_result
    );
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_id);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
