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
-- Name: assert(boolean, text, text[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION assert(assertion boolean, message text DEFAULT ''::text, detail text[] DEFAULT '{}'::text[]) RETURNS score
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.assert(assertion boolean, message text DEFAULT '')
    Description:  Validate a test assertion
    Affects:      nothing
    Arguments:    assertion (boolean): result of assertion
                  message (text): descrition of the test (optional)
                  detail (text[]): array of text with detail on the test performed if FAIL (optional)
    Returns:      dis.score
*/
DECLARE
    _state      text := 'FAIL';
    _message    text := COALESCE(message, '');
    _detail     text := COALESCE(detail, '{}'::text[]);
    _score      dis.score;
BEGIN
    IF assertion IS NOT DISTINCT FROM TRUE THEN
        _state  := 'OK';
        _detail := '{}'::text[];
    END IF;
    _score := (_state, _message, _detail)::dis.score;
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.assert(assertion boolean, message text, detail text[]) OWNER TO postgres;

--
-- Name: FUNCTION assert(assertion boolean, message text, detail text[]); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION assert(assertion boolean, message text, detail text[]) IS 'Validate a test assertion (2012-03-19)';


--
-- PostgreSQL database dump complete
--

