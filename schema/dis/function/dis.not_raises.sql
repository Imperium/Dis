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
-- Name: not_raises(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_raises(call text, notwant text DEFAULT NULL::text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.not_raises(call text, notwant text DEFAULT NULL, message text DEFAULT '')
    Description:  Test if "call" does not result in the error "notwant"
    Affects:      nothing
    Arguments:    call (text): SQL to execute
                  notwant (text): SQLSTATE (equal) or SQLERRM (match) not wanted if NULL any Error is a failure (Optional)
                  message (text): Message to include (Optional)
    Returns:      dis.score
*/
DECLARE
    _score      dis.score;
    _state      text := NULL;
    _errm       text := NULL;
BEGIN
    IF notwant IS NULL THEN
        NULL;
    ELSEIF notwant ~ '^[A-Z0-9]{5}$' THEN
        _state := notwant;
    ELSE
        _errm  := notwant;
    END IF;

    BEGIN
        EXECUTE call;
    EXCEPTION
        WHEN OTHERS THEN
            IF notwant IS NULL OR SQLSTATE = _state OR SQLERRM ~* _errm THEN
                _score := (
                    'FAIL',
                    message,
                    ARRAY[
                        ('call: ' || call),
                        ('have: ' || SQLSTATE || '/' || SQLERRM || ' (SQLSTATE/SQLERRM)'),
                        ('notwant: ' || COALESCE(_state || ' (SQLSTATE)', _errm || ' (SQLERRM)', 'Any Error'))
                    ]
                );
            ELSE
                _score := ('OK', message, '{}')::dis.score;
            END IF;
            RETURN _score;
    END;

    _score := ('OK', message, '{}')::dis.score;
    RETURN _score;
END;
$_$;


ALTER FUNCTION dis.not_raises(call text, notwant text, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_raises(call text, notwant text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_raises(call text, notwant text, message text) IS 'Test if "call" results in the error "notwant" (2012-04-11)';


--
-- PostgreSQL database dump complete
--

