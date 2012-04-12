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
-- Name: raises(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION raises(call text, want text DEFAULT NULL::text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.raises(call text, want text DEFAULT NULL, message text DEFAULT '')
    Description:  Test if "call" results in the error "want"
    Affects:      nothing
    Arguments:    call (text): SQL to execute
                  want (text): SQLSTATE (equal) or SQLERRM (match) expected if NULL any Error is a success (Optional)
                  message (text): Message to include (Optional)
    Returns:      dis.score
*/
DECLARE
    _score      dis.score;
    _state      text := NULL;
    _errm       text := NULL;
BEGIN
    IF want IS NULL THEN
        NULL;
    ELSEIF want ~ '^[A-Z0-9]{5}$' THEN
        _state := want;
    ELSE
        _errm  := want;
    END IF;

    BEGIN
        EXECUTE call;
    EXCEPTION
        WHEN OTHERS THEN
            IF want IS NULL OR SQLSTATE = _state OR SQLERRM ~* _errm THEN
                _score := ('OK', message, '{}')::dis.score;
            ELSE
                _score := (
                    'FAIL',
                    message,
                    ARRAY[
                        ('call: ' || call),
                        ('have: ' || SQLSTATE || '/' || SQLERRM || ' (SQLSTATE/SQLERRM)'),
                        ('want: ' || COALESCE(_state || ' (SQLSTATE)', _errm || ' (SQLERRM)', 'Any Error'))
                    ]
                );
            END IF;
            RETURN _score;
    END;

    _score := (
        'FAIL',
        message,
        ARRAY[
            ('call: ' || call),
            ('have: no error raised'),
            ('want: ' || COALESCE(_state || ' (SQLSTATE)', _errm || ' (SQLERRM)', 'Any Error'))
        ]
    )::dis.score;
    RETURN _score;
END;
$_$;


ALTER FUNCTION dis.raises(call text, want text, message text) OWNER TO postgres;

--
-- Name: FUNCTION raises(call text, want text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION raises(call text, want text, message text) IS 'Test if "call" results in the error "want" (2012-04-11)';


--
-- PostgreSQL database dump complete
--

