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
-- Name: no_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION no_result(call text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.no_result(call text, message text DEFAULT '')
    Description:  Test if the provided query returns no results
    Affects:      nothing, unless the query performs an action
    Arguments:    call (text): query to execute
                  message (text): Mesage to include (optional)
    Returns:      dis.score
*/
DECLARE
    _count      integer;
    _score      dis.score;
BEGIN
    _count := dis._count(call);
    _score := dis.assert(
        _count = 0,
        message,
        ARRAY[
            ('call: ' || call),
            ('have: ' || COALESCE(_count || ' results', 'failed to execute')),
            ('want: no results')
        ]
    );
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.no_result(call text, message text) OWNER TO postgres;

--
-- Name: FUNCTION no_result(call text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION no_result(call text, message text) IS 'Test if the provided query returns no results (2012-04-14)';


--
-- PostgreSQL database dump complete
--

