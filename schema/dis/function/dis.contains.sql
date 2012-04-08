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
-- Name: contains(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION contains(have anyarray, want anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.contains(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have contains the array of objects in want
                  *NOTE* have and want must be of the same type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  want (anyarray): Array of values that should be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 @> $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: contain the elements in ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.contains(have anyarray, want anyarray, message text) OWNER TO postgres;

--
-- Name: contains(anyarray, anynonarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION contains(have anyarray, want anynonarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.contains(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have contains want
                  *NOTE* have must be an array of the want type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  want (anynonarray): Value that should be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 @> ARRAY[$2],
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: contain the element ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.contains(have anyarray, want anynonarray, message text) OWNER TO postgres;

--
-- Name: FUNCTION contains(have anyarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION contains(have anyarray, want anyarray, message text) IS 'Test to see if have contains the array of objects in want (2012-03-23)';


--
-- Name: FUNCTION contains(have anyarray, want anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION contains(have anyarray, want anynonarray, message text) IS 'Test to see if have contains want (2012-03-23)';


--
-- PostgreSQL database dump complete
--

