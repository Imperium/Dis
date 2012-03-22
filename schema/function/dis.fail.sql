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
-- Name: fail(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION fail(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.fail(message text DEFAULT '')
    Description:  Return a fail score
    Affects:      nothing
    Arguments:    message (text): Message to include
    Returns:      dis.score
*/
    SELECT ('FAIL',COALESCE($1,''),'{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.fail(message text) OWNER TO postgres;

--
-- Name: FUNCTION fail(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION fail(message text) IS 'DR: Return a fail score (2012-03-21)';


--
-- PostgreSQL database dump complete
--

