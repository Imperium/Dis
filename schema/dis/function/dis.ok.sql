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
-- Name: ok(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION ok(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.ok(message text DEFAULT '')
    Description:  Return an OK score
    Affects:      nothing
    Arguments:    message (text): Message to include
    Returns:      dis.score
*/
    SELECT ('OK',COALESCE($1,''),'{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.ok(message text) OWNER TO postgres;

--
-- Name: FUNCTION ok(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION ok(message text) IS 'DR: Return an ok score (2012-03-21)';


--
-- PostgreSQL database dump complete
--

