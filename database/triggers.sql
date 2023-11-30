CREATE OR REPLACE TRIGGER trg_after_insert_objednavka
AFTER INSERT ON objednavka
FOR EACH ROW
DECLARE
    v_celkovy_pocet POKOJE_TERMINU.celkovy_pocet_pokoju%TYPE;
    v_pocet_obsazenych POKOJE_TERMINU.pocet_obsazenych_pokoju%TYPE;
BEGIN
    SELECT celkovy_pocet_pokoju, pocet_obsazenych_pokoju
    INTO v_celkovy_pocet, v_pocet_obsazenych
    FROM POKOJE_TERMINU
    WHERE pokoj_id = :NEW.pokoj_id
    AND termin_id = :NEW.termin_id;

    IF v_pocet_obsazenych < v_celkovy_pocet THEN
        UPDATE POKOJE_TERMINU
        SET pocet_obsazenych_pokoju = v_pocet_obsazenych + 1
        WHERE pokoj_id = :NEW.pokoj_id
        AND termin_id = :NEW.termin_id;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Žádné volné místo pro pokoj_id a termin_id.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Žádné data pro pokoj_id a termin_id nalezeno POKOJE_TERMINU.');
END;
/

CREATE OR REPLACE TRIGGER trg_after_delete_objednavka
AFTER DELETE ON objednavka
FOR EACH ROW
DECLARE
    v_celkovy_pocet POKOJE_TERMINU.celkovy_pocet_pokoju%TYPE;
    v_pocet_obsazenych POKOJE_TERMINU.pocet_obsazenych_pokoju%TYPE;
BEGIN
    SELECT pocet_obsazenych_pokoju INTO v_pocet_obsazenych
    FROM POKOJE_TERMINU
    WHERE pokoj_id = :OLD.pokoj_id
    AND termin_id = :OLD.termin_id;

    IF v_pocet_obsazenych > 0 THEN
        UPDATE POKOJE_TERMINU
        SET pocet_obsazenych_pokoju = v_pocet_obsazenych - 1
        WHERE pokoj_id = :OLD.pokoj_id
        AND termin_id = :OLD.termin_id;
    END IF;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Pro zadané pokoj_id a termin_id bylo vráceno více řádků.');
    WHEN NO_DATA_FOUND THEN
        NULL; 
END;
/

CREATE OR REPLACE TRIGGER trg_check_age_before_insert_or_update
BEFORE INSERT OR UPDATE ON osoba
FOR EACH ROW
DECLARE
  age_in_years NUMBER;
BEGIN
  age_in_years := MONTHS_BETWEEN(SYSDATE, :NEW.datum_narozeni) / 12;
  IF age_in_years <= 18 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Osoba musí být starší víc než 18 ket.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_update_pocet_osob
AFTER INSERT ON osoba_objednavka
FOR EACH ROW
BEGIN
    UPDATE objednavka o
    SET o.pocet_osob = (SELECT COUNT(*)
                        FROM osoba_objednavka oo
                        WHERE oo.objednavka_objednavka_id = :NEW.objednavka_objednavka_id)
    WHERE o.objednavka_id = :NEW.objednavka_objednavka_id;
END;
/


CREATE OR REPLACE TRIGGER trg_after_delete_osoba_objednavka
AFTER DELETE ON osoba_objednavka
FOR EACH ROW
BEGIN
    UPDATE objednavka o
    SET o.pocet_osob = (SELECT COUNT(*)
                        FROM osoba_objednavka oo
                        WHERE oo.objednavka_objednavka_id = :OLD.objednavka_objednavka_id)
    WHERE o.objednavka_id = :OLD.objednavka_objednavka_id;
END;
/

CREATE OR REPLACE TRIGGER trg_after_ins_upd_osoba_objednavka
FOR INSERT OR UPDATE ON osoba_objednavka
COMPOUND TRIGGER

    TYPE t_objednavka_ids IS TABLE OF objednavka.objednavka_id%TYPE INDEX BY PLS_INTEGER;
    v_objednavka_ids t_objednavka_ids;

    PROCEDURE add_id(p_id objednavka.objednavka_id%TYPE) IS
    BEGIN
        IF NOT v_objednavka_ids.EXISTS(p_id) THEN
            v_objednavka_ids(p_id) := p_id;
        END IF;
    END add_id;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            add_id(:NEW.objednavka_objednavka_id);
        ELSIF UPDATING THEN
            add_id(:NEW.objednavka_objednavka_id);
            IF :NEW.objednavka_objednavka_id != :OLD.objednavka_objednavka_id THEN
                add_id(:OLD.objednavka_objednavka_id);
            END IF;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN v_objednavka_ids.FIRST..v_objednavka_ids.LAST LOOP
            IF v_objednavka_ids.EXISTS(i) THEN
                update_pocet_osob(v_objednavka_ids(i));
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_after_ins_upd_osoba_objednavka;
/


CREATE OR REPLACE TRIGGER trg_after_del_osoba_objednavka
FOR DELETE ON osoba_objednavka
COMPOUND TRIGGER

    -- Collection to store objednavka IDs
    TYPE t_objednavka_ids IS TABLE OF objednavka.objednavka_id%TYPE INDEX BY PLS_INTEGER;
    v_objednavka_ids t_objednavka_ids;

    -- Procedure to add ID to collection
    PROCEDURE add_id(p_id objednavka.objednavka_id%TYPE) IS
    BEGIN
        IF NOT v_objednavka_ids.EXISTS(p_id) THEN
            v_objednavka_ids(p_id) := p_id;
        END IF;
    END add_id;

    -- Before delete for each row, store the objednavka ID
    BEFORE EACH ROW IS
    BEGIN
        add_id(:OLD.objednavka_objednavka_id);
    END BEFORE EACH ROW;

    -- After all deletes are done, update pocet_osob for each stored objednavka ID
    AFTER STATEMENT IS
    BEGIN
        FOR i IN v_objednavka_ids.FIRST..v_objednavka_ids.LAST LOOP
            IF v_objednavka_ids.EXISTS(i) THEN
                update_pocet_osob(v_objednavka_ids(i));
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END trg_after_del_osoba_objednavka;
/

CREATE OR REPLACE PROCEDURE update_pocet_osob(
    p_objednavka_id IN OBJEDNAVKA.OBJEDNAVKA_ID%TYPE
) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM OSOBA_OBJEDNAVKA
    WHERE OBJEDNAVKA_OBJEDNAVKA_ID = p_objednavka_id;

    UPDATE OBJEDNAVKA
    SET POCET_OSOB = v_count
    WHERE OBJEDNAVKA_ID = p_objednavka_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- IDK
        RAISE;
END update_pocet_osob;
/

CREATE OR REPLACE TRIGGER update_castka_after_pocet_osob_change
AFTER UPDATE OF pocet_osob, pojisteni_id ON objednavka
FOR EACH ROW
DECLARE
  v_castka DECIMAL(10,2);
BEGIN
  v_castka := pck_utils.calculate_castka(:NEW.pojisteni_id, :NEW.termin_id, :NEW.pocet_osob);
  
  UPDATE platba
  SET castka = v_castka
  WHERE objednavka_id = :NEW.objednavka_id;
END;
/
