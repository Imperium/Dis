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
-- Name: assert(boolean, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION assert(assertion boolean, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $$
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
    _score      dis.score;
BEGIN
    IF assertion IS NOT DISTINCT FROM TRUE THEN
        _state := 'OK';
    END IF;
    _score := (_state, _message)::dis.score;
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.assert(assertion boolean, message text) OWNER TO postgres;

--
-- Name: FUNCTION assert(assertion boolean, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION assert(assertion boolean, message text) IS 'Validate a test assertion (2012-03-14)';


--
-- PostgreSQL database dump complete
--

