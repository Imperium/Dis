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
-- Name: status_agg(text); Type: AGGREGATE; Schema: dis; Owner: postgres
--

CREATE AGGREGATE status_agg(text) (
    SFUNC = status_test,
    STYPE = text
);


ALTER AGGREGATE dis.status_agg(text) OWNER TO postgres;

--
-- Name: AGGREGATE status_agg(text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON AGGREGATE status_agg(text) IS 'Aggregate test status (2012-03-15)';


--
-- PostgreSQL database dump complete
--

