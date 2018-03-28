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
  projektor_3D VARCHAR(1)  DEFAULT 'F' CHECK( projektor_3D  IN ('T','F')),
  projektor_HFR VARCHAR(1)  DEFAULT 'F' CHECK( projektor_HFR  IN ('T','F')),
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
  "3D" VARCHAR(1)  DEFAULT 'F' CHECK( "3D"  IN ('T','F')),
  HFR VARCHAR(1)  DEFAULT 'F' CHECK( HFR  IN ('T','F')),
  SAL_cislo_salu INT NOT NULL,
  FILM_id_film INT NOT NULL,
  zakladni_cena INT NOT NULL,
  cena_dite INT NULL,
  cena_senior INT NULL,
  PRIMARY KEY (id_projekce)
);
ALTER TABLE PROJEKCE ADD CONSTRAINT FK_SAL  FOREIGN KEY (SAL_cislo_salu) REFERENCES SAL(cislo_salu);
ALTER TABLE PROJEKCE ADD CONSTRAINT FK_FILM FOREIGN KEY (FILM_id_film)   REFERENCES FILM(id_film);

-- -----------------------------------------------------
-- Table ZANR
-- -----------------------------------------------------

CREATE TABLE  ZANR (
  id_zanr INT  DEFAULT NULL,
  nazev varchar(20)  DEFAULT NULL,
  PRIMARY KEY (id_zanr)
);
CREATE UNIQUE INDEX Zanr_nazev_uindex ON ZANR (nazev);

-- -----------------------------------------------------
-- Table OSOBA
-- -----------------------------------------------------

CREATE TABLE  OSOBA (
  id_osoba INT DEFAULT NULL,
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


-- -----------------------------------------------------
-- Table ZAMESTNANEC
-- -----------------------------------------------------

CREATE TABLE  ZAMESTNANEC (
  id_osoba INT PRIMARY KEY REFERENCES Osoba(id_osoba),
  funkce VARCHAR(15)  DEFAULT 'pokladni' CHECK( funkce  IN ('pokladni', 'vedouci','udrzbar'))
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
  vekova_kategorie VARCHAR(20) DEFAULT 'dospely' CHECK( vekova_kategorie  IN ('dite','dospely','senior')),
  PROJEKCE_id_projekce INT NOT NULL,
  ZAMESTNANEC_id_osoba INT NOT NULL,
  ZAKAZNIK_id_osoba INT NOT NULL,
  PRIMARY KEY (id_vstupenka)
);
ALTER TABLE VSTUPENKA ADD CONSTRAINT FK_PROJEKCE    FOREIGN KEY (PROJEKCE_id_projekce) REFERENCES PROJEKCE(id_projekce);
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
CREATE OR REPLACE TRIGGER kontrola_mailu
AFTER INSERT OR UPDATE
ON OSOBA
FOR EACH ROW
DECLARE 
MAIL_EX EXCEPTION;
BEGIN
IF NOT REGEXP_LIKE(:NEW.email,'[a-zA-Z0-9-]+@([a-zA-Z0-9]+\.[a-zA-Z0-9]+\.?[a-zA-Z0-9]+)+') THEN  
RAISE MAIL_EX;
END IF;

EXCEPTION
WHEN MAIL_EX THEN
RAISE_APPLICATION_ERROR(-20001, 'Email nema platny format!');
END;
/

-- Zkušební INSERTY
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (1, 'Marek', 'Kovalcik',  TO_DATE('1997/02/13', 'yyyy/mm/dd'), 'xkoval14@stud.fit.vutbr.cz', 123456789, 'Opava', 'Sinicni', 42);
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (2, 'Ondrej', 'Valusek', TO_DATE('1996/10/07', 'yyyy/mm/dd'), 'xvalus02@stud.fit.vutbr.cz', 987154321, 'Opava', 'Hlavni', 2);
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni)
    VALUES (3, 'Clint', 'Eastwood',  TO_DATE('1946/05/25', 'yyyy/mm/dd'));
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni)
    VALUES (4, 'Brad', 'Pitt',  TO_DATE('1971/06/25', 'yyyy/mm/dd'));
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni)
    VALUES (5, 'Jirina', 'Bohdalova',  TO_DATE('1958/01/1', 'yyyy/mm/dd'));
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (6, 'Jan', 'Novak',  TO_DATE('1983/01/18', 'yyyy/mm/dd'), 'novak@bestcinema.com', 333456789, 'Opava', 'Kvetinova', 3);
INSERT INTO OSOBA (id_osoba, jmeno, prijmeni, datum_narozeni, email, telefon, mesto, ulice, cislo_popisne)
    VALUES (7, 'Petr', 'Klic',  TO_DATE('1973/09/9', 'yyyy/mm/dd'), 'klic@bestcinema.com', 334556789, 'Opava', 'Ostravska', 62);
    
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (1, 'komedie');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (2, 'horror');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (3, 'romanticky');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (4, 'akcni');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (5, 'dokumentarni');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (6, 'drama');
INSERT INTO ZANR (id_zanr,nazev)
    VALUES (7, 'pohadka');
    
 INSERT INTO MULTIKINO (id_kino,nazev,mesto,ulice,cislo_popisne)
    VALUES (1, 'Super cinema Praha','Praha','Nakupni',3);  
 INSERT INTO MULTIKINO (id_kino,nazev,mesto,ulice,cislo_popisne)
    VALUES (2, 'Super cinema Brno','Brno','Zabavni',1);   
 INSERT INTO MULTIKINO (id_kino,nazev,mesto,ulice,cislo_popisne)
    VALUES (3, 'Super cinema Opava','Opava','Dlouha',4);  
    
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (1, 240,'T','T',1);   
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (2, 200,'T','T',1); 
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (3, 180,'T','F',1); 

INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (4, 150,'T','F',2);   
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (5, 130,'F','F',2); 
    
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (6, 150,'T','F',3);   
INSERT INTO SAL (cislo_salu,kapacita,projektor_3D,projektor_HFR,MULTIKINO_ID_KINO)
    VALUES (7, 130,'F','F',3); 
    
    
 INSERT INTO HEREC (id_osoba,narodnost)
    VALUES (3,'US');    
 INSERT INTO HEREC (id_osoba,narodnost)
    VALUES (4,'US'); 
 INSERT INTO HEREC (id_osoba,narodnost)
    VALUES (5,'CZ');
    
INSERT INTO ZAMESTNANEC (id_osoba,funkce)
    VALUES (6,'pokladni');
INSERT INTO ZAMESTNANEC (id_osoba,funkce)
    VALUES (7,'vedouci');
    
INSERT INTO ZAKAZNIK (id_osoba,vernostni_body)
    VALUES (6,90);
INSERT INTO ZAKAZNIK (id_osoba,vernostni_body)
    VALUES (7,150);


INSERT INTO FILM (id_film,nazev,rok_vzniku,popis)
    VALUES (1,'Gran Torino',TO_DATE(2008,'yyyy'),'Film vypráví příběh neústupného válečného veterána Walta Kowalského, který si s přibývajícím věkem uvědomuje, že na nový svět už nestačí. Musí se konfrontovat jak se sousedy rozličného etnického původu, tak se svými hluboce zakořeněnými předsudky.');

INSERT INTO FILM (id_film,nazev,rok_vzniku,popis)
    VALUES (2,'Rakosnicek a hvezdy',TO_DATE(1975,'yyyy'),'První z příběhů o Rákosníčkovi. Rákosníček jako hvězdář napravuje maléry na noční obloze. Dalším pokračováním je RÁKOSNÍČEK A JEHO RYBNÍK (1983), které bývá ještě rozdělováno na samostatnou část RÁKOSNÍČEK A POVĚTŘÍ..');

INSERT INTO FILM (id_film,nazev,rok_vzniku,popis)
    VALUES (3,'Titanic',TO_DATE(1997,'yyyy'),'Byl obrovský a luxusní. Lidé o něm ve své pýše říkali, že je nepotopitelný. Když vyplouval Titanic na svou první plavbu, byli na jeho palubě také chudý Jack a bohatá Rose. On vyhrál lístek v pokeru, ona měla pronajato jedno z nejluxusnějších apartmá. Prožili spolu nejkrásnější chvíle života a slíbili si, že už se nikdy nerozejdou - až do oné osudné noci, kdy pýcha lidstva narazila v Severním moři do ledovce, který Titanic neúprosně poslal ke dnu. ');

INSERT INTO FILM (id_film,nazev,rok_vzniku,popis)
    VALUES (4,'Neobycejne zivoty: Jirina Bohdalova',TO_DATE(2009,'yyyy'),'Jedna z nejpopulárnějších českých hereček rekapituluje svoji životní a profesní dráhu. Vzpomíná na svá setkání s významnými osobnostmi kulturního života, jako byl Rudolf Deyl ml., Vlasta Chramostová, Martin Frič, Jan Werich, Radoslav Brzobohatý, Vladimír Dvořák, Jiří Hubač či Karel Šíp.');


INSERT INTO HERCI_VE_FILMECH(HEREC_id_osoba,FILM_id_film)
    VALUES (3,1);
INSERT INTO HERCI_VE_FILMECH(HEREC_id_osoba,FILM_id_film)
    VALUES (5,2);
INSERT INTO HERCI_VE_FILMECH(HEREC_id_osoba,FILM_id_film)
    VALUES (4,3);
INSERT INTO HERCI_VE_FILMECH(HEREC_id_osoba,FILM_id_film)
    VALUES (5,4);
    
INSERT INTO ZANRY_VE_FILMU(FILM_id_film,ZANR_id_zanr)
    VALUES (1,6);
INSERT INTO ZANRY_VE_FILMU(FILM_id_film,ZANR_id_zanr)
    VALUES (2,7);    
INSERT INTO ZANRY_VE_FILMU(FILM_id_film,ZANR_id_zanr)
    VALUES (3,6);
INSERT INTO ZANRY_VE_FILMU(FILM_id_film,ZANR_id_zanr)
    VALUES (4,5);

INSERT INTO PROJEKCE(id_projekce,SAL_CISLO_SALU,FILM_ID_FILM,datum,cas,"3D",HFR,zakladni_cena,cena_dite,cena_senior)
    VALUES (1,1,2,TO_DATE('2018/02/18','yyyy/mm/dd'),TO_TIMESTAMP('15:00','HH24:MI'),'F','F',190,100,120);
INSERT INTO PROJEKCE(id_projekce,SAL_CISLO_SALU,FILM_ID_FILM,datum,cas,"3D",HFR,zakladni_cena,cena_dite,cena_senior)
    VALUES (2,1,2,TO_DATE('2018/02/18','yyyy/mm/dd'),TO_TIMESTAMP('17:00','HH24:MI'),'F','F',190,100,120); 
INSERT INTO PROJEKCE(id_projekce,SAL_CISLO_SALU,FILM_ID_FILM,datum,cas,"3D",HFR,zakladni_cena,cena_dite,cena_senior)
    VALUES (3,2,1,TO_DATE('2018/02/18','yyyy/mm/dd'),TO_TIMESTAMP('20:00','HH24:MI'),'T','F',190,100,120); 

INSERT INTO VSTUPENKA(id_vstupenka,sedadlo,vekova_kategorie,PROJEKCE_ID_PROJEKCE,ZAMESTNANEC_ID_OSOBA,ZAKAZNIK_ID_OSOBA)
    VALUES (1,20,'dite',1,6,1); 

INSERT INTO VSTUPENKA(id_vstupenka,sedadlo,vekova_kategorie,PROJEKCE_ID_PROJEKCE,ZAMESTNANEC_ID_OSOBA,ZAKAZNIK_ID_OSOBA)
    VALUES (2,21,'dospely',1,6,1); 
    
INSERT INTO VSTUPENKA(id_vstupenka,sedadlo,vekova_kategorie,PROJEKCE_ID_PROJEKCE,ZAMESTNANEC_ID_OSOBA,ZAKAZNIK_ID_OSOBA)
    VALUES (3,55,'dospely',2,6,2);
INSERT INTO VSTUPENKA(id_vstupenka,sedadlo,vekova_kategorie,PROJEKCE_ID_PROJEKCE,ZAMESTNANEC_ID_OSOBA,ZAKAZNIK_ID_OSOBA)
    VALUES (4,56,'dospely',2,6,2);

SELECT * FROM SAL;
SELECT * FROM OSOBA;
