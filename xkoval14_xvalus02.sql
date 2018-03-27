--
-- Marek Kovalčík, xkoval14
-- Ondřej Valušek, xvalus02
--

-- -----------------------------------------------------
-- Table MULTIKINO
-- -----------------------------------------------------
DROP TABLE FILM CASCADE CONSTRAINTS;
DROP TABLE HEREC CASCADE CONSTRAINTS;
DROP TABLE MULTIKINO CASCADE CONSTRAINTS;
DROP TABLE OSOBA CASCADE CONSTRAINTS;
DROP TABLE PROJEKCE CASCADE CONSTRAINTS;
DROP TABLE SAL CASCADE CONSTRAINTS;
DROP TABLE VSTUPENKA CASCADE CONSTRAINTS;
DROP TABLE ZAKAZNIK CASCADE CONSTRAINTS;
DROP TABLE ZAMESTNANEC CASCADE CONSTRAINTS;
DROP TABLE ZANR CASCADE CONSTRAINTS;
DROP TABLE ZANRY_VE_FILMU CASCADE CONSTRAINTS;
DROP TABLE HERCI_VE_FILMECH CASCADE CONSTRAINTS;

CREATE TABLE  MULTIKINO (
  id_kino INT NOT NULL,
  nazev VARCHAR(50) NOT NULL,
  mesto VARCHAR(50) NOT NULL,
  ulice VARCHAR(50)  DEFAULT NULL,
  cislo_popisne INT  DEFAULT NULL,
  PRIMARY KEY (id_kino)
);
CREATE UNIQUE INDEX Multikino_nazev_uindex ON MULTIKINO (nazev);


-- -----------------------------------------------------
-- Table SAL
-- -----------------------------------------------------

CREATE TABLE  SAL (
  cislo_salu INT  DEFAULT NULL,
  kapacita INT NOT NULL,
  P3D_projektor VARCHAR(1)  DEFAULT 'F' CHECK( P3D_projektor  IN ('T','F')),
  HFR_projektor VARCHAR(1)  DEFAULT 'F' CHECK( HFR_projektor  IN ('T','F')),
  MULTIKINO_id_kino INT NOT NULL,
  PRIMARY KEY (cislo_salu)
);
ALTER TABLE SAL ADD CONSTRAINT FK_id_kino FOREIGN KEY (MULTIKINO_id_kino) REFERENCES MULTIKINO(id_kino);

-- -----------------------------------------------------
-- Table FILM
-- -----------------------------------------------------
CREATE TABLE  FILM (
  id_film INT DEFAULT NULL,
  nazev VARCHAR(50) NOT NULL,
  rok_vzniku DATE NOT NULL,
  popis VARCHAR(500)  DEFAULT NULL,
  PRIMARY KEY (id_film));


-- -----------------------------------------------------
-- Table PROJEKCE
-- -----------------------------------------------------

CREATE TABLE  PROJEKCE (
  id_projekce INT DEFAULT NULL,
  datum DATE NOT NULL,
  cas TIMESTAMP NOT NULL,
  P3D VARCHAR(1)  DEFAULT 'F' CHECK( P3D  IN ('T','F')),
  HFR VARCHAR(1)  DEFAULT 'F' CHECK( HFR  IN ('T','F')),
  SAL_cislo_salu INT NOT NULL,
  FILM_id_film INT NOT NULL,
  PRIMARY KEY (id_projekce)
);
ALTER TABLE PROJEKCE ADD CONSTRAINT FK_SAL  FOREIGN KEY (SAL_cislo_salu) REFERENCES SAL(cislo_salu);
ALTER TABLE PROJEKCE ADD CONSTRAINT FK_FILM FOREIGN KEY (FILM_id_film)   REFERENCES FILM(id_film);

-- -----------------------------------------------------
-- Table ZANR
-- -----------------------------------------------------

CREATE TABLE  ZANR (
  id_zanr INT  DEFAULT NULL,
  nazev INT  DEFAULT NULL,
  PRIMARY KEY (id_zanr)
);
CREATE UNIQUE INDEX Zanr_nazev_uindex ON ZANR (nazev);

-- -----------------------------------------------------
-- Table OSOBA
-- -----------------------------------------------------

CREATE TABLE  OSOBA (
  id_osoba INT DEFAULT NULL,
  rodne_cislo INT NOT NULL,
  jmeno VARCHAR(50) NOT NULL,
  prijmeni VARCHAR(50) NOT NULL,
  datum_narozeni DATE NOT NULL,
  email VARCHAR(50)  DEFAULT NULL,
  telefon INT  DEFAULT NULL,
  mesto VARCHAR(50)  DEFAULT NULL,
  ulice VARCHAR(50)  DEFAULT NULL,
  cislo_popisne INT  DEFAULT NULL,
  PRIMARY KEY (id_osoba)
);
CREATE UNIQUE INDEX Osoba_rodne_cislo_uindex ON OSOBA (rodne_cislo);


-- -----------------------------------------------------
-- Table ZAMESTNANEC
-- -----------------------------------------------------

CREATE TABLE  ZAMESTNANEC (
  id_osoba INT PRIMARY KEY REFERENCES Osoba(id_osoba),
  funkce VARCHAR(15)  DEFAULT 'pokladni' CHECK( funkce  IN ('pokladni', 'vedouci'))
);

-- -----------------------------------------------------
-- Table ZAKAZNIK
-- -----------------------------------------------------

CREATE TABLE  ZAKAZNIK (
  id_osoba INT PRIMARY KEY REFERENCES Osoba(id_osoba),
  vernostni_body INT DEFAULT 0
);

-- -----------------------------------------------------
-- Table VSTUPENKA
-- -----------------------------------------------------

CREATE TABLE  VSTUPENKA (
  id_vstupenka INT  DEFAULT NULL,
  sedadlo INT NOT NULL,
  vekova_kategorie INT NOT NULL,
  cena DECIMAL NOT NULL,
  PROJEKCE_id_projekce INT NOT NULL,
  ZAMESTNANEC_id_osoba INT NOT NULL,
  ZAKAZNIK_id_osoba INT NOT NULL,
  PRIMARY KEY (id_vstupenka)
);
ALTER TABLE VSTUPENKA ADD CONSTRAINT FK_VSTUPENKA    FOREIGN KEY (PROJEKCE_id_projekce) REFERENCES PROJEKCE(id_projekce);
ALTER TABLE VSTUPENKA ADD CONSTRAINT FK_ZAMESTNANEC  FOREIGN KEY (ZAMESTNANEC_id_osoba) REFERENCES OSOBA(id_osoba);
ALTER TABLE VSTUPENKA ADD CONSTRAINT FK_ZAKAZNIK     FOREIGN KEY (ZAKAZNIK_id_osoba)    REFERENCES OSOBA(id_osoba);

-- -----------------------------------------------------
-- Table HEREC
-- -----------------------------------------------------

CREATE TABLE  HEREC (
  id_osoba INT PRIMARY KEY REFERENCES Osoba(id_osoba),
  narodnost VARCHAR(3) NOT NULL
);

-- -----------------------------------------------------
-- Table ZANRY_VE_FILMU
-- -----------------------------------------------------

CREATE TABLE  ZANRY_VE_FILMU (
  FILM_id_film INT NOT NULL,
  ZANR_id_zanr INT NOT NULL,
  PRIMARY KEY (FILM_id_film, ZANR_id_zanr)
);
ALTER TABLE ZANRY_VE_FILMU ADD CONSTRAINT FK_FILM_HAS_ZANR_ZANR1 FOREIGN KEY (ZANR_id_zanr)    REFERENCES ZANR(id_zanr);
ALTER TABLE ZANRY_VE_FILMU ADD CONSTRAINT FK_FILM_HAS_ZANR_FILM1 FOREIGN KEY (FILM_id_film)    REFERENCES FILM(id_film);

-- -----------------------------------------------------
-- Table HERCI_VE_FILMECH
-- -----------------------------------------------------

CREATE TABLE  HERCI_VE_FILMECH (
  HEREC_id_osoba INT NOT NULL,
  FILM_id_film INT NOT NULL,
  PRIMARY KEY (HEREC_id_osoba, FILM_id_film)
);
ALTER TABLE HERCI_VE_FILMECH ADD CONSTRAINT FK_HEREC_has_FILM_HEREC1 FOREIGN KEY (HEREC_id_osoba)  REFERENCES OSOBA(id_osoba);
ALTER TABLE HERCI_VE_FILMECH ADD CONSTRAINT Fk_HEREC_has_FILM_FILM1  FOREIGN KEY (FILM_id_film)    REFERENCES FILM(id_film);

-- Zkušební INSERTY
INSERT INTO OSOBA (id_osoba, rodne_cislo, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (1, 9635136547, 'Marek', 'Kovalcik',  TO_DATE('1997/02/13', 'yyyy/mm/dd'), 'xkoval14@stud.fit.vutbr.cz', 123456789, 'Opava', 'Sinicni', 42);
INSERT INTO OSOBA (id_osoba, rodne_cislo, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (2, 9660245874, 'Ondrej', 'Vlkodlak', TO_DATE('1996/10/07', 'yyyy/mm/dd'), 'xvalus02@stud.fit.vutbr.cz', 987654321, 'Opava', 'Pod mostem', 69);
INSERT INTO OSOBA (id_osoba, rodne_cislo, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (3, 5685655226, 'Clint', 'Eastwood',  TO_DATE('1956/05/25', 'yyyy/mm/dd'), 'eastwood@fit.vutbr.cz', 5698745233, 'New York', '1st Avenue', 99);
SELECT * FROM OSOBA;
