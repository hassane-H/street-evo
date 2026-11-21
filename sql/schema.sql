-- ============================================================================
-- 1. Nettoyage complet
-- ============================================================================
DROP TABLE IF EXISTS public.exercice_realise;
DROP TABLE IF EXISTS public.serie;
DROP TABLE IF EXISTS public.seance;
DROP TABLE IF EXISTS public.exercice;

DROP DOMAIN IF EXISTS public.d_type_mesure;
DROP DOMAIN IF EXISTS public.d_categorie;
DROP DOMAIN IF EXISTS public.d_type_execution;

-- ============================================================================
-- 2. Domaines
-- ============================================================================
CREATE DOMAIN public.d_categorie AS character varying
    CONSTRAINT d_categorie_check CHECK (
        VALUE IN ('tirer', 'pousser', 'jambe', 'gainage', 'autre')
    );


CREATE DOMAIN public.d_type_execution AS character varying
    CONSTRAINT d_type_execution_check CHECK (
        VALUE IN ('normale', 'lente', 'dynamique')
    );


CREATE DOMAIN public.d_type_mesure AS character varying
    CONSTRAINT d_type_mesure_check CHECK (
        VALUE IN ('repetition', 'duree')
    );




-- ============================================================================
-- 3. Tables
-- ============================================================================

-- Table : public.seance
CREATE TABLE IF NOT EXISTS public.seance (
    id_seance   integer           NOT NULL GENERATED ALWAYS AS IDENTITY,
    date_seance date              NOT NULL,
    note        character varying,
    CONSTRAINT seance_pkey PRIMARY KEY (id_seance)
);



-- Table : public.exercice
CREATE TABLE IF NOT EXISTS public.exercice (
    nom         character varying    NOT NULL,
    type_mesure public.d_type_mesure NOT NULL,
    categorie   public.d_categorie   NOT NULL,
    CONSTRAINT exercice_pkey PRIMARY KEY (nom)
);




-- Table : public.serie
CREATE TABLE IF NOT EXISTS public.serie (
    id_serie     integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    id_seance    integer NOT NULL,
    numero_serie integer NOT NULL,
    repos        integer NOT NULL DEFAULT 0,
    CONSTRAINT serie_pkey PRIMARY KEY (id_serie),
    CONSTRAINT serie_position_unique UNIQUE (numero_serie, id_seance),
    CONSTRAINT serie_id_seance_fkey FOREIGN KEY (id_seance)
        REFERENCES public.seance (id_seance)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT serie_numero_positif CHECK (numero_serie > 0),
    CONSTRAINT serie_repos_positif CHECK (repos >= 0)
);




-- Table : public.exercice_realise
CREATE TABLE IF NOT EXISTS public.exercice_realise (
    id_exercice_realise integer                 NOT NULL GENERATED ALWAYS AS IDENTITY,
    id_serie            integer                 NOT NULL,
    nom                 character varying       NOT NULL,
    ordre               integer                 NOT NULL,
    repetition          integer,
    duree               integer,
    charge              numeric(5,2)            NOT NULL DEFAULT 0,
    type_execution      public.d_type_execution NOT NULL DEFAULT 'normale',
    CONSTRAINT exercice_realise_pkey PRIMARY KEY (id_exercice_realise),
    CONSTRAINT er_position_unique UNIQUE (id_serie, ordre),
    CONSTRAINT exercice_realise_id_serie_fkey FOREIGN KEY (id_serie)
        REFERENCES public.serie (id_serie)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT exercice_realise_nom_fkey FOREIGN KEY (nom)
        REFERENCES public.exercice (nom)
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT er_charge_positive CHECK (charge >= 0),
    CONSTRAINT er_duree_positive CHECK (duree > 0),
    CONSTRAINT er_ordre_positif CHECK (ordre > 0),
    CONSTRAINT er_repetition_positive CHECK (repetition > 0),
    CONSTRAINT mesure_unique CHECK ((repetition IS NULL) <> (duree IS NULL))
);

