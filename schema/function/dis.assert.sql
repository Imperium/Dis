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
-- Name: assert(assertion boolean, message text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION assert(assertion boolean, message text DEFAULT '') RETURNS dis.score 
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.assert(assertion boolean, message text DEFAULT '')
    Description:  Validate a test assertion
    Affects:      nothing
    Arguments:    assertion (boolean): result of assertion
                  message (text): descrition of the test
    Returns:      text
*/
DECLARE
    _state      text := 'FAIL';
    _message    text := COALESCE(message, '');
BEGIN
    IF assertion IS NOT DISTINCT FROM TRUE THEN
        state := 'OK';
    END IF;

    RETURN (_state, _message)::dis.score;
END;
$_$;


ALTER FUNCTION dis.assert(assertion boolean, message text) OWNER TO postgres;

--
-- Name: FUNCTION assert(assertion boolean, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION assert(assertion boolean, message text) IS 'Validate a test assertion (2012-03-14)';


--
-- PostgreSQL database dump complete
--
