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
-- Name: not_contains(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_contains(have anyarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_contains(have anyarray, notwant anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have does not contain the array of objects in notwant
                  *NOTE* have and notwant must be of the same type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  notwant (anyarray): Array of values that should not be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        NOT $1 @> $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: should not contain the elements in ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_contains(have anyarray, notwant anyarray, message text) OWNER TO postgres;

--
-- Name: not_contains(anyarray, anynonarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_contains(have anyarray, notwant anynonarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_contains(have anyarray, notwant anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have does not contain notwant
                  *NOTE* have must be an array of the notwant type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  notwant (anynonarray): Value that should not be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        NOT $1 @> ARRAY[$2],
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: should not contain the element ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_contains(have anyarray, notwant anynonarray, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_contains(have anyarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_contains(have anyarray, notwant anyarray, message text) IS 'DR: Test to see if have does not contain the array of objects in notwant (2012-03-23)';


--
-- Name: FUNCTION not_contains(have anyarray, notwant anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_contains(have anyarray, notwant anynonarray, message text) IS 'DR: Test to see if have does not contain notwant (2012-03-23)';


--
-- PostgreSQL database dump complete
--

