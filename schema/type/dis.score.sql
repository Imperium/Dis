--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis, pg_catalog;

--
-- Name: score; Type: TYPE; Schema: dis; Owner: postgres
--

CREATE TYPE score AS (
	status text,
	message text
);


ALTER TYPE dis.score OWNER TO postgres;

--
-- Name: TYPE score; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TYPE score IS 'Assertion test output (2012-03-14)';


--
-- PostgreSQL database dump complete
--

