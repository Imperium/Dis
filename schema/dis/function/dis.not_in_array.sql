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
-- Name: not_in_array(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_in_array(have anyarray, want anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_in_array(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have elements are not contained by want
                  *NOTE* have and want must be of the same type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  want (anyarray): Array of values that should not include elements in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 @> $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: each not one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_in_array(have anyarray, want anyarray, message text) OWNER TO postgres;

--
-- Name: not_in_array(anynonarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_in_array(have anynonarray, want anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_in_array(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have is not contained by want
                  *NOTE* want must be an array of the have type
    Affects:      nothing
    Arguments:    have (anynonarray): Array to test
                  want (anyarray): Value that should not be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 @> ARRAY[$2],
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: not one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_in_array(have anynonarray, want anyarray, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_in_array(have anyarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anyarray, want anyarray, message text) IS 'DR: Test to see if have elements are not contained by want (2012-03-23)';


--
-- Name: FUNCTION not_in_array(have anynonarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anynonarray, want anyarray, message text) IS 'DR: Test to see if have is not contained by want (2012-03-23)';


--
-- PostgreSQL database dump complete
--

