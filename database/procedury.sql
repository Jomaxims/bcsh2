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

