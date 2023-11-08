-- Generated by Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   at:        2023-11-08 17:47:00 CET
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE adresa (
    adresa_id     INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    ulice         VARCHAR2(50) NOT NULL,
    cislo_popisne VARCHAR2(10) NOT NULL,
    mesto         VARCHAR2(100) NOT NULL,
    psc           VARCHAR2(20) NOT NULL,
    poznamka      VARCHAR2(250),
    stat_id       INTEGER NOT NULL
);

ALTER TABLE adresa ADD CONSTRAINT adresa_pk PRIMARY KEY ( adresa_id );

CREATE TABLE doprava (
    doprava_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    nazev      VARCHAR2(50) NOT NULL
);

ALTER TABLE doprava ADD CONSTRAINT doprava_pk PRIMARY KEY ( doprava_id );

CREATE TABLE kontakt (
    kontakt_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    email      VARCHAR2(50) NOT NULL,
    telefon    VARCHAR2(20) NOT NULL,
    osoba_id   INTEGER NOT NULL
);

CREATE UNIQUE INDEX kontakt__idx ON
    kontakt (
        osoba_id
    ASC );

ALTER TABLE kontakt ADD CONSTRAINT kontakt_pk PRIMARY KEY ( kontakt_id );

CREATE TABLE log_tabel (
    log_id    INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    tabulka   VARCHAR2(32) NOT NULL,
    operace   VARCHAR2(15) NOT NULL,
    cas_zmeny TIMESTAMP NOT NULL,
    uzivatel  VARCHAR2(20) NOT NULL,
    pred      CLOB,
    po        CLOB
);

ALTER TABLE log_tabel ADD CONSTRAINT log_pk PRIMARY KEY ( log_id );

CREATE TABLE objednavka (
    objednavka_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    pocet_osob    INTEGER NOT NULL,
    termin_id     INTEGER NOT NULL,
    pojisteni_id  INTEGER,
    pokoj_id      INTEGER NOT NULL,
    zakaznik_id   INTEGER NOT NULL
);

ALTER TABLE objednavka ADD CONSTRAINT objednavka_pk PRIMARY KEY ( objednavka_id );

CREATE TABLE obrazky_ubytovani (
    obrazky_ubytovani_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    obrazek              BLOB NOT NULL,
    poradi               INTEGER NOT NULL,
    ubytovani_id         INTEGER NOT NULL
);

ALTER TABLE obrazky_ubytovani ADD CONSTRAINT obrazky_ubytovani_pk PRIMARY KEY ( obrazky_ubytovani_id );

CREATE TABLE osoba (
    osoba_id  INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    jmeno     VARCHAR2(50) NOT NULL,
    prijmeni  VARCHAR2(50) NOT NULL,
    vek       NUMBER(3) NOT NULL,
    adresa_id INTEGER NOT NULL
);

CREATE UNIQUE INDEX osoba__idx ON
    osoba (
        adresa_id
    ASC );

ALTER TABLE osoba ADD CONSTRAINT osoba_pk PRIMARY KEY ( osoba_id );

CREATE TABLE osoba_objednavka (
    osoba_osoba_id           INTEGER NOT NULL,
    objednavka_objednavka_id INTEGER NOT NULL
);

ALTER TABLE osoba_objednavka ADD CONSTRAINT osoba_objednavka_pk PRIMARY KEY ( osoba_osoba_id,
                                                                              objednavka_objednavka_id );

CREATE TABLE platba (
    platba_id        INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    castka           NUMBER(2) NOT NULL,
    datum_splatnosti DATE NOT NULL,
    cislo_uctu       VARCHAR2(30) NOT NULL,
    objednavka_id    INTEGER NOT NULL,
    zaplacena        NUMBER NOT NULL
);

CREATE UNIQUE INDEX platba__idx ON
    platba (
        objednavka_id
    ASC );

ALTER TABLE platba ADD CONSTRAINT platba_pk PRIMARY KEY ( platba_id );

CREATE TABLE pojisteni (
    pojisteni_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    cena_za_den  NUMBER(2) NOT NULL,
    popis        VARCHAR2(500) NOT NULL
);

ALTER TABLE pojisteni ADD CONSTRAINT pojisteni_pk PRIMARY KEY ( pojisteni_id );

CREATE TABLE pokoj (
    pokoj_id   INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    pocet_mist NUMBER(2) NOT NULL,
    nazev      VARCHAR2(50) NOT NULL
);

ALTER TABLE pokoj ADD CONSTRAINT pokoj_pk PRIMARY KEY ( pokoj_id );

CREATE TABLE pokoje_terminu (
    celkovy_pocet_pokoju    INTEGER NOT NULL,
    pocet_obsazenych_pokoju INTEGER NOT NULL,
    termin_id               INTEGER NOT NULL,
    pokoj_id                INTEGER NOT NULL
);

ALTER TABLE pokoje_terminu ADD CONSTRAINT pokoje_terminu_pk PRIMARY KEY ( termin_id,
                                                                          pokoj_id );

CREATE TABLE prihlasovaci_udaje (
    prihlasovaci_udaje_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    jmeno                 VARCHAR2(50) NOT NULL,
    heslo                 VARCHAR2(50) NOT NULL
);

ALTER TABLE prihlasovaci_udaje ADD CONSTRAINT prihlasovaci_udaje_pk PRIMARY KEY ( prihlasovaci_udaje_id );

CREATE TABLE role (
    role_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    nazev   VARCHAR2(11) NOT NULL
);

ALTER TABLE role ADD CONSTRAINT role_pk PRIMARY KEY ( role_id );

CREATE TABLE stat (
    stat_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    zkratka VARCHAR2(3) NOT NULL,
    nazev   VARCHAR2(100) NOT NULL
);

ALTER TABLE stat ADD CONSTRAINT stat_pk PRIMARY KEY ( stat_id );

CREATE TABLE strava (
    strava_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    nazev     VARCHAR2(50) NOT NULL
);

ALTER TABLE strava ADD CONSTRAINT strava_pk PRIMARY KEY ( strava_id );

CREATE TABLE termin (
    termin_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    od        DATE NOT NULL,
    do        DATE NOT NULL,
    zajezd_id INTEGER
);

ALTER TABLE termin ADD CONSTRAINT termin_pk PRIMARY KEY ( termin_id );

CREATE TABLE ubytovani (
    ubytovani_id INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    nazev        VARCHAR2(100) NOT NULL,
    popis        VARCHAR2(1000) NOT NULL,
    kapacita     INTEGER NOT NULL,
    obsazenost   INTEGER NOT NULL,
    adresa_id    INTEGER NOT NULL,
    pocet_hvezd  NUMBER NOT NULL
);

CREATE UNIQUE INDEX ubytovani__idx ON
    ubytovani (
        adresa_id
    ASC );

ALTER TABLE ubytovani ADD CONSTRAINT ubytovani_pk PRIMARY KEY ( ubytovani_id );

CREATE TABLE zajezd (
    zajezd_id     INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    popis         VARCHAR2(500),
    cena_za_osobu NUMBER NOT NULL,
    doprava_id    INTEGER NOT NULL,
    ubytovani_id  INTEGER NOT NULL,
    sleva_procent NUMBER,
    zobrazit      NUMBER NOT NULL,
    strava_id     INTEGER NOT NULL
);

ALTER TABLE zajezd ADD CONSTRAINT zajezd_pk PRIMARY KEY ( zajezd_id );

CREATE TABLE zakaznik (
    zakaznik_id           INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    prihlasovaci_udaje_id INTEGER NOT NULL,
    osoba_id              INTEGER NOT NULL
);

CREATE UNIQUE INDEX zakaznik__idx ON
    zakaznik (
        prihlasovaci_udaje_id
    ASC );

CREATE UNIQUE INDEX zakaznik__idxv1 ON
    zakaznik (
        osoba_id
    ASC );

ALTER TABLE zakaznik ADD CONSTRAINT zakaznik_pk PRIMARY KEY ( zakaznik_id );

CREATE TABLE zamestnanec (
    zamestnanec_id        INTEGER
        GENERATED BY DEFAULT AS IDENTITY ( START WITH 1 NOCACHE ORDER )
    NOT NULL,
    role_id               INTEGER NOT NULL,
    prihlasovaci_udaje_id INTEGER NOT NULL,
    nadrizeny_id          INTEGER,
    jmeno                 VARCHAR2(50) NOT NULL,
    prijmeni              VARCHAR2(50) NOT NULL
);

CREATE UNIQUE INDEX zamestnanec__idx ON
    zamestnanec (
        prihlasovaci_udaje_id
    ASC );

ALTER TABLE zamestnanec ADD CONSTRAINT zamestnanec_pk PRIMARY KEY ( zamestnanec_id );

ALTER TABLE adresa
    ADD CONSTRAINT adresa_stat_fk FOREIGN KEY ( stat_id )
        REFERENCES stat ( stat_id );

ALTER TABLE kontakt
    ADD CONSTRAINT kontakt_osoba_fk FOREIGN KEY ( osoba_id )
        REFERENCES osoba ( osoba_id );

ALTER TABLE objednavka
    ADD CONSTRAINT objednavka_pojisteni_fk FOREIGN KEY ( pojisteni_id )
        REFERENCES pojisteni ( pojisteni_id );

ALTER TABLE objednavka
    ADD CONSTRAINT objednavka_pokoj_fk FOREIGN KEY ( pokoj_id )
        REFERENCES pokoj ( pokoj_id );

ALTER TABLE objednavka
    ADD CONSTRAINT objednavka_termin_fk FOREIGN KEY ( termin_id )
        REFERENCES termin ( termin_id );

ALTER TABLE objednavka
    ADD CONSTRAINT objednavka_zakaznik_fk FOREIGN KEY ( zakaznik_id )
        REFERENCES zakaznik ( zakaznik_id );

ALTER TABLE obrazky_ubytovani
    ADD CONSTRAINT obrazky_ubytovani_ubytovani_fk FOREIGN KEY ( ubytovani_id )
        REFERENCES ubytovani ( ubytovani_id );

ALTER TABLE osoba
    ADD CONSTRAINT osoba_adresa_fk FOREIGN KEY ( adresa_id )
        REFERENCES adresa ( adresa_id );

ALTER TABLE osoba_objednavka
    ADD CONSTRAINT osoba_objednavka_objednavka_fk FOREIGN KEY ( objednavka_objednavka_id )
        REFERENCES objednavka ( objednavka_id );

ALTER TABLE osoba_objednavka
    ADD CONSTRAINT osoba_objednavka_osoba_fk FOREIGN KEY ( osoba_osoba_id )
        REFERENCES osoba ( osoba_id );

ALTER TABLE platba
    ADD CONSTRAINT platba_objednavka_fk FOREIGN KEY ( objednavka_id )
        REFERENCES objednavka ( objednavka_id );

ALTER TABLE pokoje_terminu
    ADD CONSTRAINT pokoje_terminu_pokoj_fk FOREIGN KEY ( pokoj_id )
        REFERENCES pokoj ( pokoj_id );

ALTER TABLE pokoje_terminu
    ADD CONSTRAINT pokoje_terminu_termin_fk FOREIGN KEY ( termin_id )
        REFERENCES termin ( termin_id );

ALTER TABLE termin
    ADD CONSTRAINT termin_zajezd_fk FOREIGN KEY ( zajezd_id )
        REFERENCES zajezd ( zajezd_id );

ALTER TABLE ubytovani
    ADD CONSTRAINT ubytovani_adresa_fk FOREIGN KEY ( adresa_id )
        REFERENCES adresa ( adresa_id );

ALTER TABLE zajezd
    ADD CONSTRAINT zajezd_doprava_fk FOREIGN KEY ( doprava_id )
        REFERENCES doprava ( doprava_id );

ALTER TABLE zajezd
    ADD CONSTRAINT zajezd_strava_fk FOREIGN KEY ( strava_id )
        REFERENCES strava ( strava_id );

ALTER TABLE zajezd
    ADD CONSTRAINT zajezd_ubytovani_fk FOREIGN KEY ( ubytovani_id )
        REFERENCES ubytovani ( ubytovani_id );

ALTER TABLE zakaznik
    ADD CONSTRAINT zakaznik_osoba_fk FOREIGN KEY ( osoba_id )
        REFERENCES osoba ( osoba_id );

ALTER TABLE zakaznik
    ADD CONSTRAINT zakaznik_prihlasovaci_udaje_fk FOREIGN KEY ( prihlasovaci_udaje_id )
        REFERENCES prihlasovaci_udaje ( prihlasovaci_udaje_id );

ALTER TABLE zamestnanec
    ADD CONSTRAINT zamestnanec_prihlasovaci_udaje_fk FOREIGN KEY ( prihlasovaci_udaje_id )
        REFERENCES prihlasovaci_udaje ( prihlasovaci_udaje_id );

ALTER TABLE zamestnanec
    ADD CONSTRAINT zamestnanec_role_fk FOREIGN KEY ( role_id )
        REFERENCES role ( role_id );

ALTER TABLE zamestnanec
    ADD CONSTRAINT zamestnanec_zamestnanec_fk FOREIGN KEY ( nadrizeny_id )
        REFERENCES zamestnanec ( zamestnanec_id );



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            21
-- CREATE INDEX                             7
-- ALTER TABLE                             44
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
