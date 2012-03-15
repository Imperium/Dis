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
-- Name: todo(message text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION todo(message text DEFAULT 'Test Placeholder') RETURNS dis.score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.todo(message text DEFAULT 'Test Placeholder')
    Description:  Placdholder for a real test to be added later
    Affects:      nothing
    Arguments:    message text: Message to include
    Returns:      dis.score
*/
    SELECT ('TODO', $1)::dis.score;
$_$;


ALTER FUNCTION dis.todo(message text) OWNER TO postgres;

--
-- Name: FUNCTION todo(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION todo(message text) IS 'DR: Placdholder for a real test to be added later (2012-03-15)';


--
-- PostgreSQL database dump complete
--
