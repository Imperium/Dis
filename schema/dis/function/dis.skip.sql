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
-- Name: skip(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION skip(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.skip(message text DEFAULT '')
    Description:  Return a test skip score
    Affects:      nothing
    Arguments:    message text DEFAULT 'Skipped Test': Message to include in the dis.score
    Returns:      dis.score
*/
    SELECT ('SKIP', COALESCE($1,''), '{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.skip(message text) OWNER TO postgres;

--
-- Name: FUNCTION skip(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION skip(message text) IS 'Return a test skip score (2012-03-15)';


--
-- PostgreSQL database dump complete
--

