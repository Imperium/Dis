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
-- Name: status_test(initial_value text, next_value text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION status_test(initial_value text, next_value text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.status_test(initial_value text, next_value text)
    Description:  Determine state for dis.status_agg(text)
    Affects:      nothing
    Arguments:    initial_value (text): starting value
                  next_value (text): next value
    Returns:      text
*/
DECLARE
BEGIN
    IF initial_value NOT IN ('OK', 'TODO', 'SKIP') THEN
        RETURN 'FAIL';
    ELSEIF next_value NOT IN ('OK', 'TODO', 'SKIP') THEN
        RETURN 'FAIL';
    END IF;
    RETURN 'OK';
END;
$_$;


ALTER FUNCTION dis.status_test(initial_value text, next_value text) OWNER TO postgres;

--
-- Name: FUNCTION status_test(initial_value text, next_value text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION status_test(initial_value text, next_value text) IS 'Determine state for dis.status_agg(text) (2012-03-16)';


--
-- PostgreSQL database dump complete
--
