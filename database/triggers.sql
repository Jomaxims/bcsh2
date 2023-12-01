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

CREATE OR REPLACE TRIGGER trg_update_pocet_osob
AFTER INSERT ON osoba_objednavka
FOR EACH ROW
DECLARE
  v_pocet_osob INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_pocet_osob
  FROM osoba_objednavka
  WHERE objednavka_id = :NEW.objednavka_id;

  UPDATE objednavka
  SET pocet_osob = v_pocet_osob + 1
  WHERE objednavka_id = :NEW.objednavka_id;
END;


CREATE OR REPLACE TRIGGER trg_update_pocet_osob_del
AFTER DELETE ON osoba_objednavka
DECLARE
  v_pocet_osob INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_pocet_osob
  FROM osoba_objednavka
  WHERE objednavka_id = :NEW.objednavka_id;

  UPDATE objednavka
  SET pocet_osob = v_pocet_osob + 1
  WHERE objednavka_id = :NEW.objednavka_id;
END;
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
