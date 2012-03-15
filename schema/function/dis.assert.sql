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

CREATE OR REPLACE FUNCTION assert(boolean, text DEFAULT '') RETURNS dis.score 
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.assert(boolean, text DEFAULT '')
    Description:  Validate a test assertion
    Affects:      nothing
    Arguments:    boolean: result of assertion of truth
                  text: descrition of the test
    Returns:      text
*/
DECLARE
    v_assert    ALIAS FOR $1;
    _state      text := 'FAIL';
    _message    text := COALESCE($2, '');
BEGIN
    IF v_assert IS NOT DISTINCT FROM TRUE THEN
        state := 'OK';
    END IF;

    RETURN (_state, _message)::dis.score;
END;
$_$;


ALTER FUNCTION dis.assert(boolean, text) OWNER TO postgres;

--
-- Name: FUNCTION assert(boolean, text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION assert(boolean, text) IS 'Validate a test assertion (2012-03-14)';


--
-- PostgreSQL database dump complete
--
