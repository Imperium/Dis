BEGIN;


--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: dis; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis;


ALTER SCHEMA dis OWNER TO postgres;

--
-- Name: dis; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis FROM PUBLIC;
REVOKE ALL ON SCHEMA dis FROM postgres;
GRANT ALL ON SCHEMA dis TO postgres;
GRANT ALL ON SCHEMA dis TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: dis_history; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_history;


ALTER SCHEMA dis_history OWNER TO postgres;

--
-- Name: dis_history; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_history FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_history FROM postgres;
GRANT ALL ON SCHEMA dis_history TO postgres;
GRANT ALL ON SCHEMA dis_history TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: dis_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_test;


ALTER SCHEMA dis_test OWNER TO postgres;

--
-- Name: dis_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_test FROM postgres;
GRANT ALL ON SCHEMA dis_test TO postgres;
GRANT ALL ON SCHEMA dis_test TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: dis_v1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_v1;


ALTER SCHEMA dis_v1 OWNER TO postgres;

--
-- Name: dis_v1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_v1 FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_v1 FROM postgres;
GRANT ALL ON SCHEMA dis_v1 TO postgres;
GRANT ALL ON SCHEMA dis_v1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: score; Type: TYPE; Schema: dis; Owner: postgres
--

CREATE TYPE score AS (
    status text,
    message text,
    detail text[]
);


ALTER TYPE dis.score OWNER TO postgres;

--
-- Name: TYPE score; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TYPE score IS 'Assertion test output (2012-03-19)';


--
-- PostgreSQL database dump complete
--

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

COMMENT ON FUNCTION contains(have anyarray, want anyarray, message text) IS 'DR: Test to see if have contains the array of objects in want (2012-03-23)';


--
-- Name: FUNCTION contains(have anyarray, want anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION contains(have anyarray, want anynonarray, message text) IS 'DR: Test to see if have contains want (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: fail(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION fail(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.fail(message text DEFAULT '')
    Description:  Return a fail score
    Affects:      nothing
    Arguments:    message (text): Message to include
    Returns:      dis.score
*/
    SELECT ('FAIL',COALESCE($1,''),'{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.fail(message text) OWNER TO postgres;

--
-- Name: FUNCTION fail(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION fail(message text) IS 'DR: Return a fail score (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: greater(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION greater(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.greater(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is greater than want
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value that have should be greater than
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 > $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: value greater than ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.greater(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION greater(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION greater(have anyelement, want anyelement, message text) IS 'DR: Test if have is greater than want (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: greater_equal(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION greater_equal(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.greater_equal(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is greater than or equal to want
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value that have should be greater than or equal to
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 >= $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: value greater than or equal to ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.greater_equal(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION greater_equal(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION greater_equal(have anyelement, want anyelement, message text) IS 'DR: Test if have is greater than or equal to want (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: imatch(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION imatch(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.imatch(have text, regex text, message text DEFAULT '')
    Description:  Test if have matches regex, case insensitive
    Affects:      nothing
    Arguments:    have (text): Text that should match the provided regular expression, case insensitive
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 ~* $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: match the regular expression, case insensitive, ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.imatch(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION imatch(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION imatch(have text, regex text, message text) IS 'DR: Test if have matches regex, case insensitive (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: in_array(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION in_array(have anyarray, want anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.in_array(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have elements are contained by want
                  *NOTE* have and want must be of the same type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  want (anyarray): Array of values that should include elements in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 <@ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: each one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.in_array(have anyarray, want anyarray, message text) OWNER TO postgres;

--
-- Name: in_array(anynonarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION in_array(have anynonarray, want anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.in_array(have anyarray, want anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have is contained by want
                  *NOTE* want must be an array of the have type
    Affects:      nothing
    Arguments:    have (anynonarray): Array to test
                  want (anyarray): Value that should be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        ARRAY[$1] <@ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.in_array(have anynonarray, want anyarray, message text) OWNER TO postgres;

--
-- Name: FUNCTION in_array(have anyarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION in_array(have anyarray, want anyarray, message text) IS 'DR: Test to see if have elements are contained by want (2012-03-23)';


--
-- Name: FUNCTION in_array(have anynonarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION in_array(have anynonarray, want anyarray, message text) IS 'DR: Test to see if have is contained by want (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: less(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION less(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.less(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is less than want
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value that have should be less than
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 < $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: value less than ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.less(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION less(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION less(have anyelement, want anyelement, message text) IS 'DR: Test if have is less than want (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: less_equal(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION less_equal(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.less_equal(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is less than or equal to want
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value that have should be less than or equal to
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 <= $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: value less than or equal to ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.less_equal(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION less_equal(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION less_equal(have anyelement, want anyelement, message text) IS 'DR: Test if have is less than or equal to want (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: match(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION match(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.match(have text, regex text, message text DEFAULT '')
    Description:  Test if have matches regex
    Affects:      nothing
    Arguments:    have (text): Text that should match the provided regular expression
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 ~ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: match the regular expression ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.match(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION match(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION match(have text, regex text, message text) IS 'DR: Test if have matches regex (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: modified(); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION modified() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.modified()
    Description:  Properly set modified_at modified_by
    Affects:      Active record
    Arguments:    none
    Returns:      trigger
*/
DECLARE
BEGIN
    NEW.modified_at := CURRENT_TIMESTAMP;
    NEW.modified_by := CURRENT_USER;
    RETURN NEW;
END;
$$;


ALTER FUNCTION dis.modified() OWNER TO postgres;

--
-- Name: FUNCTION modified(); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION modified() IS 'Properly set modified_at modified_by (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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
-- Name: no_imatch(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION no_imatch(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.no_imatch(have text, regex text, message text DEFAULT '')
    Description:  Test if have does not match regex, case insensitive
    Affects:      nothing
    Arguments:    have (text): Text that should not match the provided regular expression, case insensitive
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 !~* $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: do not match the regular expression, case insensitive, ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.no_imatch(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION no_imatch(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION no_imatch(have text, regex text, message text) IS 'DR: Test if have does not match regex, case insensitive (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: no_match(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION no_match(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.no_match(have text, regex text, message text DEFAULT '')
    Description:  Test if have does not match regex
    Affects:      nothing
    Arguments:    have (text): Text that should not match the provided regular expression
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 !~ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: do not match the regular expression ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.no_match(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION no_match(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION no_match(have text, regex text, message text) IS 'DR: Test if have does not match regex (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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

CREATE OR REPLACE FUNCTION not_in_array(have anyarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_in_array(have anyarray, notwant anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have elements are not contained by notwant
                  *NOTE* have and notwant must be of the same type
    Affects:      nothing
    Arguments:    have (anyarray): Array to test
                  notwant (anyarray): Array of values that should not include elements in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        NOT $1 <@ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: each not one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_in_array(have anyarray, notwant anyarray, message text) OWNER TO postgres;

--
-- Name: not_in_array(anynonarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_in_array(have anynonarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_in_array(have anyarray, notwant anyarray, message text DEFAULT ''::text)
    Description:  Test to see if have is not contained by notwant
                  *NOTE* notwant must be an array of the have type
    Affects:      nothing
    Arguments:    have (anynonarray): Array to test
                  notwant (anyarray): Value that should not be in have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        NOT ARRAY[$1] <@ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: not one of ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_in_array(have anynonarray, notwant anyarray, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_in_array(have anyarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anyarray, notwant anyarray, message text) IS 'DR: Test to see if have elements are not contained by notwant (2012-03-23)';


--
-- Name: FUNCTION not_in_array(have anynonarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anynonarray, notwant anyarray, message text) IS 'DR: Test to see if have is not contained by notwant (2012-03-23)';


--
-- PostgreSQL database dump complete
--

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
-- Name: not_same(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_same(have anyelement, notwant anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_same(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is distinct from want
                  *NOTE* "have" and "notwant" must be of the same type
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  notwant (anyelement): value to test against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 IS DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('notwant: ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.not_same(have anyelement, notwant anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_same(have anyelement, notwant anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_same(have anyelement, notwant anyelement, message text) IS 'Test if have is distinct from want (2012-03-20)';


--
-- PostgreSQL database dump complete
--

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
-- Name: not_type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_type(have anyelement, notwant regtype, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_type(have anyelement, notwant regtype, message text)
    Description:  Check if have is not the provided regtype
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  notwant (regtype): Postgres regtype name to check against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        pg_typeof($1) IS DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have type: ' || COALESCE(pg_typeof($1)::text, 'NULL')),
            ('notwant type: ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.not_type(have anyelement, notwant regtype, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_type(have anyelement, notwant regtype, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_type(have anyelement, notwant regtype, message text) IS 'DR: Check if have is not the provided regtype (2012-03-20)';


--
-- PostgreSQL database dump complete
--

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
-- Name: ok(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION ok(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.ok(message text DEFAULT '')
    Description:  Return an OK score
    Affects:      nothing
    Arguments:    message (text): Message to include
    Returns:      dis.score
*/
    SELECT ('OK',COALESCE($1,''),'{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.ok(message text) OWNER TO postgres;

--
-- Name: FUNCTION ok(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION ok(message text) IS 'DR: Return an ok score (2012-03-21)';


--
-- PostgreSQL database dump complete
--

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
-- Name: run_test(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_test(test_schema text, test_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.run_test(test_schema text, test_name text)
    Description:  Run a test and record the results
    Affects:      
    Arguments:    
    Returns:      boolean
*/
DECLARE
    _test       dis.test%ROWTYPE;
    _tally      text[];
    _status     text        := 'FAIL';
    _count      integer     := 1;
    _scores     dis.score[] := '{}'::dis.score[];
    _scorecount integer     := 0;
    _success    integer     := 0;
    _failure    integer     := 0;
    _summary    text;
    _i          integer;
BEGIN
    SELECT * INTO _test FROM dis.test AS test WHERE test.schema = test_schema AND test.name = test_name;
    IF _test.name IS NULL THEN
        RAISE EXCEPTION 'Test %.% does not exist', test_schema, test_name;
    END IF;
    DELETE FROM dis.result WHERE schema = test_schema AND name = test_name;

    BEGIN
        PERFORM dis.test_wrapper(test_schema, test_name);
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' AND SQLERRM ~ E'^\\[(\\w+)\\]\\[(\\d+)\\]\\[(\\d+)\\]\\[(\\d+)\\](.*)$' THEN
                _tally   := regexp_matches(SQLERRM, E'^\\[(\\w+)\\]\\[(\\d+)\\]\\[(\\d+)\\]\\[(\\d+)\\](.*)$');
                _status  := _tally[1];
                _count   := _tally[2]::integer;
                _success := _tally[3]::integer;
                _failure := _tally[4]::integer;
                _scores  := _tally[5]::dis.score[];
                IF _status = 'NONE' THEN
                    _summary := 'Test failed to properly report results';
                ELSEIF _status = 'FAIL' THEN
                    _summary := _failure::text ||  ' of ' || _count::text || ' assertions failed';
                ELSEIF _test.plan <> _count THEN
                    _status := 'FAIL';
                    _summary := 'Test plan of ' || _test.plan::text || ' assertions not followed, ' || _count::text || ' assertions reported';
                ELSE
                    _summary := _success::text || ' of ' || _count::text || ' assertions passed';
                END IF;
            ELSE
                _summary := SQLERRM;
            END IF;
            INSERT INTO dis.result (name, schema, module, submodule, plan, status, tests, successes, failures, summary, detail) 
                VALUES (test_name, test_schema, _test.module, _test.submodule, _test.plan, _status, _count, _success, _failure, _summary, _scores);
    END;
    RETURN TRUE;
END;
$_$;


ALTER FUNCTION dis.run_test(test_schema text, test_name text) OWNER TO postgres;

--
-- Name: FUNCTION run_test(test_schema text, test_name text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_test(test_schema text, test_name text) IS 'DR: Run a test and record the results (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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
-- Name: run_tests(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_tests(test_schema text DEFAULT NULL::text, test_module text DEFAULT NULL::text, test_submodule text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.run_tests(test_schema text, test_module text, test_submodule text)
    Description:  Run the specified tests
    Affects:      Executes
    Arguments:    test_schema (text): (Optional) Limit run to tests in this schema
                  test_module (text): (Optional) Limit run to tests in this module
                  test_submodule (text): (Optional) Limit run to tests in this submodule
    Returns:      boolean
*/
DECLARE
BEGIN
    IF test_schema IS NULL THEN
        DELETE FROM dis.result;
        PERFORM dis.run_test(schema, name) FROM dis.test
            ORDER BY schema, module, submodule, name;
    ELSEIF test_module IS NULL THEN
        DELETE FROM dis.result WHERE schema = test_schema;
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema
            ORDER BY schema, module, submodule, name;
    ELSEIF test_submodule IS NULL THEN
        DELETE FROM dis.result WHERE schema = test_schema AND module = test_module
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema AND module = test_module
            ORDER BY schema, module, submodule, name;
    ELSE
        DELETE FROM dis.result WHERE schema = test_schema AND module = test_module AND submodule = test_submodule
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema AND module = test_module AND submodule = test_submodule
            ORDER BY schema, module, submodule, name;
    END IF;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION dis.run_tests(test_schema text, test_module text, test_submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests(test_schema text, test_module text, test_submodule text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) IS 'Run the specified tests (2012-03-16)';


--
-- Name: run_tests(text, text, text); Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) FROM PUBLIC;
REVOKE ALL ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) FROM postgres;
GRANT ALL ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) TO postgres;
GRANT ALL ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: same(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION same(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.same(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test to see if have is not distinct from want
                  *NOTE* "have" and "want" must be of the same type
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value to test against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 IS NOT DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.same(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION same(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION same(have anyelement, want anyelement, message text) IS 'Test to see if have is not distinct from want (2012-03-19)';


--
-- PostgreSQL database dump complete
--

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
-- Name: skip(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION skip(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.skip(message text DEFAULT '')
    Description:  Return a test skip score
    Affects:      nothing
    Arguments:    message text DEFAULT 'Skipped Test': Message to include in the dis.score
    Returns:      dis.score
*/
    SELECT ('SKIP', COALESCE($1,''), '{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.skip(message text) OWNER TO postgres;

--
-- Name: FUNCTION skip(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION skip(message text) IS 'Return a test skip score (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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
-- Name: status_test(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION status_test(initial_value text, next_value text) RETURNS text
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.status_test(initial_value text, next_value text)
    Description:  Determine state for dis.status_agg(text)
    Affects:      nothing
    Arguments:    initial_value (text): starting value
                  next_value (text): next value
    Returns:      text
*/
DECLARE
BEGIN
    IF initial_value NOT IN ('OK', 'TODO', 'SKIP') THEN
        RETURN 'FAIL';
    ELSEIF next_value NOT IN ('OK', 'TODO', 'SKIP') THEN
        RETURN 'FAIL';
    END IF;
    RETURN 'OK';
END;
$$;


ALTER FUNCTION dis.status_test(initial_value text, next_value text) OWNER TO postgres;

--
-- Name: FUNCTION status_test(initial_value text, next_value text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION status_test(initial_value text, next_value text) IS 'Determine state for dis.status_agg(text) (2012-03-16)';


--
-- PostgreSQL database dump complete
--

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
-- Name: tally(score[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION tally(tallies score[]) RETURNS void
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.tally(tallies dis.score[])
    Description:  Tally scores and throws exception for test reporting
    Affects:      nothing
    Arguments:    tallies (dis.score[]): array of dis.score results
    Returns:      void
*/
DECLARE
    _count      integer         := array_upper(tallies, 1);
    _state      text            := 'OK';
    _success    integer         := 0;
    _failure    integer         := 0;
    _i          integer;
BEGIN
    IF _count IS NULL THEN
        RAISE EXCEPTION '[FAIL][0][0][0]{}';
    END IF;

    FOR _i IN 1.._count LOOP
        IF tallies[_i].status IN ('OK', 'TODO', 'SKIP') THEN
            _success := _success + 1;
        ELSE
            _failure := _failure +1;
            _state   := 'FAIL';
        END IF;
    END LOOP;
    RAISE EXCEPTION '[%][%][%][%]%', _state, _count, _success, _failure, tallies::text;
END;
$$;


ALTER FUNCTION dis.tally(tallies score[]) OWNER TO postgres;

--
-- Name: FUNCTION tally(tallies score[]); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION tally(tallies score[]) IS 'Tally scores for test reporting (2012-03-14)';


--
-- PostgreSQL database dump complete
--

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
-- Name: test_wrapper(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_wrapper(schema text, name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.test_wrapper(schema text, name text)
    Description:  Test wrapper to ensure an exception is thrown
    Affects:      Executes provided function
    Arguments:    schema (text): schema of the function
                  name (text): name of the function
    Returns:      void
*/
DECLARE
BEGIN
    EXECUTE 'SELECT ' || quote_ident(schema) || '.' || quote_ident(name) || '()';
    RAISE EXCEPTION '[NONE][0][0][0]{}';
END;
$$;


ALTER FUNCTION dis.test_wrapper(schema text, name text) OWNER TO postgres;

--
-- Name: FUNCTION test_wrapper(schema text, name text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION test_wrapper(schema text, name text) IS 'DR: Test wrapper to ensure an exception is thrown (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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
-- Name: todo(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION todo(message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.todo(message text DEFAULT '')
    Description:  Placdholder for a real test to be added later
    Affects:      nothing
    Arguments:    message text: Message to include
    Returns:      dis.score
*/
    SELECT ('TODO', COALESCE($1,''), '{}'::text[])::dis.score;
$_$;


ALTER FUNCTION dis.todo(message text) OWNER TO postgres;

--
-- Name: FUNCTION todo(message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION todo(message text) IS 'DR: Placdholder for a real test to be added later (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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
-- Name: type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION type(have anyelement, want regtype, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.type(have anyelement, want regtype, message text)
    Description:  Check if have is the provided regtype
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  want (regtype): Postgres regtype name to check against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        pg_typeof($1) IS NOT DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have type: ' || COALESCE(pg_typeof($1)::text, 'NULL')),
            ('want type: ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.type(have anyelement, want regtype, message text) OWNER TO postgres;

--
-- Name: FUNCTION type(have anyelement, want regtype, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION type(have anyelement, want regtype, message text) IS 'DR: Check if have is the provided regtype (2012-03-20)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_history, pg_catalog;

--
-- Name: result_saver(); Type: FUNCTION; Schema: dis_history; Owner: postgres
--

CREATE OR REPLACE FUNCTION result_saver() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
/*  Function:     dis_history.result_saver()
    Description:  Saves each insert in history table
    Affects:      Records each test result in the history table
    Arguments:    none
    Returns:      trigger
*/
DECLARE
BEGIN
    INSERT INTO dis_history.result VALUES ((NEW).*);
    RETURN NEW;
END;
$$;


ALTER FUNCTION dis_history.result_saver() OWNER TO postgres;

--
-- Name: FUNCTION result_saver(); Type: COMMENT; Schema: dis_history; Owner: postgres
--

COMMENT ON FUNCTION result_saver() IS 'Saves each insert in history table (2012-03-16)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_120_ok(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_120_ok() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.ok functions as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.ok('OK #1'),
            ('OK', 'OK #1', '{}'::text[])::dis.score,
            'OK test with message'
        ),
        dis.same(
            dis.ok(),
            ('OK', '', '{}'::text[])::dis.score,
            'OK test with no message parameter'
        ),
        dis.assert(
            dis.ok(NULL::text) = ('OK', '', '{}'::text[])::dis.score,
            'OK test with NULL message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_120_ok() OWNER TO postgres;

--
-- Name: FUNCTION test_120_ok(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_120_ok() IS 'Ensure dis.ok functions as expected (2012-03-25)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_122_fail(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_122_fail() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.fail functions as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.fail('Fail #1'),
            ('FAIL', 'Fail #1', '{}')::dis.score,
            'Fail test with message'
        ),
        dis.same(
            dis.fail(),
            ('FAIL', '', '{}')::dis.score,
            'Fail with no message parameter'
        ),
        dis.same(
            dis.fail(NULL),
            ('FAIL', '', '{}')::dis.score,
            'Fail with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_122_fail() OWNER TO postgres;

--
-- Name: FUNCTION test_122_fail(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_122_fail() IS 'Ensure dis.fail functions as expected (DATE)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_124_todo(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_124_todo() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.todo functions as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.todo('Todo #1'),
            ('TODO', 'Todo #1', '{}')::dis.score,
            'Todo test with message'
        ),
        dis.same(
            dis.todo(),
            ('TODO', '', '{}')::dis.score,
            'Todo test with no message parameter'
        ),
        dis.same(
            dis.todo(NULL),
            ('TODO', '', '{}')::dis.score,
            'Todo test with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_124_todo() OWNER TO postgres;

--
-- Name: FUNCTION test_124_todo(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_124_todo() IS 'Ensure dis.todo functions as expected (2012-03-25)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_126_skip(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_126_skip() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.skip works as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.skip('Skip #1'),
            ('SKIP', 'Skip #1', '{}')::dis.score,
            'Skip assertion with message'
        ),
        dis.same(
            dis.skip(),
            ('SKIP', '', '{}')::dis.score,
            'Skip assertion with no message parameter'
        ),
        dis.same(
            dis.skip(NULL),
            ('SKIP', '', '{}')::dis.score,
            'Skip assertion with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_126_skip() OWNER TO postgres;

--
-- Name: FUNCTION test_126_skip(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_126_skip() IS 'Ensure dis.skip works as expected (DATE)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_130_same(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_130_same() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.same works as expected
-- plan: 5
-- module: assertions
-- submodule: same
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(
            dis.same(1, 1) = ('OK', '', '{}')::dis.score,
            'Same: OK numeric comparison'
        ),
        dis.assert(
            dis.same(0, 1) = ('FAIL', '', '{"have: 0 (integer)","want: 1 (integer)"}')::dis.score,
            'Same: FAIL numeric comparison'
        ),
        dis.assert(
            dis.same('HAVE'::text, 'HAVE') = ('OK', '', '{}')::dis.score,
            'Same: OK text comparison'
        ),
        dis.assert(
            dis.same(NULL, FALSE) = ('FAIL', '', '{"have: NULL (boolean)","want: false (boolean)"}')::dis.score,
            'Same: FAIL boolean comparison'
        ),
        dis.assert(
            dis.same(ARRAY[1,2,3,4], ARRAY[4,3,2,1]) = ('FAIL', '', '{"have: {1,2,3,4} (integer[])","want: {4,3,2,1} (integer[])"}')::dis.score,
            'Same: FAIL array comparison'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_130_same() OWNER TO postgres;

--
-- Name: FUNCTION test_130_same(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_130_same() IS 'Ensure dis.same works as expected (DATE)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_135_not_same(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_135_not_same() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_same works as expected
-- plan: 2
-- module: assertions
-- submodule: same
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_same(0, 1),
            ('OK', '', '{}')::dis.score,
            'Not Same: OK numeric comparison'
        ),
        dis.same(
            dis.not_same(1, 1),
            ('FAIL', '', '{"have: 1 (integer)","notwant: 1 (integer)"}')::dis.score,
            'Not Same: FAIL numeric comparison'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_135_not_same() OWNER TO postgres;

--
-- Name: FUNCTION test_135_not_same(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_135_not_same() IS 'Ensure dis.not_same works as expected (DATE)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_140_greater(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_140_greater() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.greater works as expected
-- plan: 5
-- module: assertions
-- submodule: relative
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.greater(3,2),
            ('OK', '', '{}')::dis.score,
            'Greater: OK numeric comparison where greater'
        ),
        dis.same(
            dis.greater(2,2),
            ('FAIL', '', '{"have: 2 (integer)","want: value greater than 2 (integer)"}')::dis.score,
            'Greater: Fail numeric comparison where equal'
        ),
        dis.same(
            dis.greater(1,2),
            ('FAIL', '', '{"have: 1 (integer)","want: value greater than 2 (integer)"}')::dis.score,
            'Greater: FAIL numeric comparison where less'
        ),
        dis.same(
            dis.greater('3'::text, '23'),
            ('OK', '', '{}')::dis.score,
            'Greater: OK text comparison where greater'
        ),
        dis.same(
            dis.greater('23'::text, '3'),
            ('FAIL', '', '{"have: 23 (text)","want: value greater than 3 (text)"}')::dis.score,
            'Greater: FAIL text comparison where less'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_140_greater() OWNER TO postgres;

--
-- Name: FUNCTION test_140_greater(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_140_greater() IS 'Ensure dis.greater works as expected (2012-03-28)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_142_greater_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_142_greater_equal() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.greater_equal works as expected
-- plan: 5
-- module: assertions
-- submodule: relative
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.greater_equal(3,2),
            ('OK', '', '{}')::dis.score,
            'Greater Equal: OK numeric comparison where greater'
        ),
        dis.same(
            dis.greater_equal(2,2),
            ('OK', '', '{}')::dis.score,
            'Greater Equal: OK numeric comparison where equal'
        ),
        dis.same(
            dis.greater_equal(1,2),
            ('FAIL', '', '{"have: 1 (integer)","want: value greater than or equal to 2 (integer)"}')::dis.score,
            'Greater Equal: FAIL numeric comparison where less'
        ),
        dis.same(
            dis.greater_equal('3'::text, '23'),
            ('OK', '', '{}')::dis.score,
            'Greater Equal: OK text comparison where greater'
        ),
        dis.same(
            dis.greater_equal('23'::text, '3'),
            ('FAIL', '', '{"have: 23 (text)","want: value greater than or equal to 3 (text)"}')::dis.score,
            'Greater Equal: FAIL text comparison where less'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_142_greater_equal() OWNER TO postgres;

--
-- Name: FUNCTION test_142_greater_equal(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_142_greater_equal() IS 'Ensure dis.greater works as expected (2012-03-28)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_144_less(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_144_less() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.less works as expected
-- plan: 5
-- module: assertions
-- submodule: relative
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.less(3,2),
            ('FAIL', '', '{"have: 3 (integer)","want: value less than 2 (integer)"}')::dis.score,
            'Less: FAIL numeric comparison where greater'
        ),
        dis.same(
            dis.less(2,2),
            ('FAIL', '', '{"have: 2 (integer)","want: value less than 2 (integer)"}')::dis.score,
            'Less: Fail numeric comparison where equal'
        ),
        dis.same(
            dis.less(1,2),
            ('OK', '', '{}')::dis.score,
            'Less: OK numeric comparison where less'
        ),
        dis.same(
            dis.less('23'::text, '3'),
            ('OK', '', '{}')::dis.score,
            'Less: OK text comparison where less'
        ),
        dis.same(
            dis.less('3'::text, '23'),
            ('FAIL', '', '{"have: 3 (text)","want: value less than 23 (text)"}')::dis.score,
            'Less: FAIL text comparison where greater'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_144_less() OWNER TO postgres;

--
-- Name: FUNCTION test_144_less(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_144_less() IS 'Ensure dis.greater works as expected (2012-03-28)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_146_less_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_146_less_equal() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.less_equal works as expected
-- plan: 5
-- module: assertions
-- submodule: relative
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.less_equal(3,2),
            ('FAIL', '', '{"have: 3 (integer)","want: value less than or equal to 2 (integer)"}')::dis.score,
            'Less Equal: FAIL numeric comparison where greater'
        ),
        dis.same(
            dis.less_equal(2,2),
            ('OK', '', '{}')::dis.score,
            'Less Equal: OK numeric comparison where equal'
        ),
        dis.same(
            dis.less_equal(1,2),
            ('OK', '', '{}')::dis.score,
            'Less Equal: FAIL numeric comparison where less'
        ),
        dis.same(
            dis.less_equal('23'::text, '3'),
            ('OK', '', '{}')::dis.score,
            'Less Equal: OK text comparison where less'
        ),
        dis.same(
            dis.less_equal('3'::text, '23'),
            ('FAIL', '', '{"have: 3 (text)","want: value less than or equal to 23 (text)"}')::dis.score,
            'Less Equal: FAIL text comparison where greater'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_146_less_equal() OWNER TO postgres;

--
-- Name: FUNCTION test_146_less_equal(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_146_less_equal() IS 'Ensure dis.greater works as expected (2012-03-28)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_150_contains(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_150_contains() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.contains works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.contains(ARRAY[1,4,7], 1),
            ('OK', '', '{}')::dis.score,
            'Contains: OK has element'
        ),
        dis.same(
            dis.contains(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('OK', '', '{}')::dis.score,
            'Contains: OK has elements'
        ),
        dis.same(
            dis.contains(ARRAY[2,4,7], 1),
            ('FAIL', '', '{"have: {2,4,7} (integer[])","want: contain the element 1 (integer)"}')::dis.score,
            'Contains: FAIL missing element'
        ),
        dis.same(
            dis.contains(ARRAY[1,4,7], ARRAY[1,4,7,10]),
            ('FAIL', '', '{"have: {1,4,7} (integer[])","want: contain the elements in {1,4,7,10} (integer[])"}')::dis.score,
            'Contains: FAIL does not contain all elements'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_150_contains() OWNER TO postgres;

--
-- Name: FUNCTION test_150_contains(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_150_contains() IS 'Ensure dis.contains works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_152_not_contains(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_152_not_contains() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_contains works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_contains(ARRAY[1,4,7], 1),
            ('FAIL', '', '{"have: {1,4,7} (integer[])","want: should not contain the element 1 (integer)"}')::dis.score,
            'Not Contains: FAIL has element'
        ),
        dis.same(
            dis.not_contains(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('FAIL', '', '{"have: {1,4,7} (integer[])","want: should not contain the elements in {4,7,1} (integer[])"}')::dis.score,
            'Not Contains: FAIL has elements'
        ),
        dis.same(
            dis.not_contains(ARRAY[2,4,7], 1),
            ('OK', '', '{}')::dis.score,
            'Not Contains: OK missing element'
        ),
        dis.same(
            dis.not_contains(ARRAY[1,4,7], ARRAY[1,4,7,10]),
            ('OK', '', '{}')::dis.score,
            'Not Contains: OK does not contain all elements'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_152_not_contains() OWNER TO postgres;

--
-- Name: FUNCTION test_152_not_contains(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_152_not_contains() IS 'Ensure dis.not_contains works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_154_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_154_in_array() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.in_array works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.in_array(1, ARRAY[1,4,7]),
            ('OK', '', '{}')::dis.score,
            'In Array: OK element in array'
        ),
        dis.same(
            dis.in_array(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('OK', '', '{}')::dis.score,
            'In Array: OK elements in array'
        ),
        dis.same(
            dis.in_array(1, ARRAY[2,4,7]),
            ('FAIL', '', '{"have: 1 (integer)","want: one of {2,4,7} (integer[])"}')::dis.score,
            'In Array: FAIL element missing from array'
        ),
        dis.same(
            dis.in_array(ARRAY[1,4,11], ARRAY[1,4,7,10]),
            ('FAIL', '', '{"have: {1,4,11} (integer[])","want: each one of {1,4,7,10} (integer[])"}')::dis.score,
            'In Array: FAIL not all elements in array'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_154_in_array() OWNER TO postgres;

--
-- Name: FUNCTION test_154_in_array(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_154_in_array() IS 'Ensure dis.in_array works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_156_not_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_156_not_in_array() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_in_array works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_in_array(1, ARRAY[1,4,7]),
            ('FAIL', '', '{"have: 1 (integer)","want: not one of {1,4,7} (integer[])"}')::dis.score,
            'Not In Array: FAIL element in array'
        ),
        dis.same(
            dis.not_in_array(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('FAIL', '', '{"have: {1,4,7} (integer[])","want: each not one of {4,7,1} (integer[])"}')::dis.score,
            'Not In Array: FAIL elements in array'
        ),
        dis.same(
            dis.not_in_array(1, ARRAY[2,4,7]),
            ('OK', '', '{}')::dis.score,
            'Not In Array: OK element missing from array'
        ),
        dis.same(
            dis.not_in_array(ARRAY[1,4,11], ARRAY[1,4,7,10]),
            ('OK', '', '{}')::dis.score,
            'Not In Array: OK not all elements in array'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_156_not_in_array() OWNER TO postgres;

--
-- Name: FUNCTION test_156_not_in_array(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_156_not_in_array() IS 'Ensure dis.not_in_array works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_160_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_160_match() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.match works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.match('This is a string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Match: OK'
        ),
        dis.same(
            dis.match('This is A string', 's is a s'),
            ('FAIL', '', '{"have: This is A string","want: match the regular expression s is a s"}')::dis.score,
            'Match: FAIL on case sensitivity'
        ),
        dis.same(
            dis.match('This is a string', '^This.*string$'),
            ('OK', '', '{}')::dis.score,
            'Match: OK with simple regex'
        ),
        dis.same(
            dis.match('This is a string', 'want'),
            ('FAIL', '', '{"have: This is a string","want: match the regular expression want"}')::dis.score,
            'Match: FAIL with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_160_match() OWNER TO postgres;

--
-- Name: FUNCTION test_160_match(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_160_match() IS 'Ensure dis.match works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_162_no_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_162_no_match() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.no_match works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.no_match('This is a string', 's is a s'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression s is a s"}')::dis.score,
            'No Match: FAIL because substring'
        ),
        dis.same(
            dis.no_match('This is A string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'No Match: OK due to case sensitivity'
        ),
        dis.same(
            dis.no_match('This is a string', '^This.*string$'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression ^This.*string$"}')::dis.score,
            'No Match: FAIL with simple regex'
        ),
        dis.same(
            dis.no_match('This is a string', 'want'),
            ('OK', '', '{}')::dis.score,
            'No Match: OK with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_162_no_match() OWNER TO postgres;

--
-- Name: FUNCTION test_162_no_match(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_162_no_match() IS 'Ensure dis.no_match works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_164_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_164_imatch() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.imatch works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.imatch('This is a string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK'
        ),
        dis.same(
            dis.imatch('This is A string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK on case insensitivity'
        ),
        dis.same(
            dis.imatch('This is a string', '^This.*string$'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK with simple regex'
        ),
        dis.same(
            dis.imatch('This is a string', 'want'),
            ('FAIL', '', '{"have: This is a string","want: match the regular expression, case insensitive, want"}')::dis.score,
            'Insensive Match: FAIL with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_164_imatch() OWNER TO postgres;

--
-- Name: FUNCTION test_164_imatch(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_164_imatch() IS 'Ensure dis.imatch works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_166_no_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_166_no_imatch() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.no_imatch works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.no_imatch('This is a string', 's is a s'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression, case insensitive, s is a s"}')::dis.score,
            'No Insensive Match: FAIL because substring'
        ),
        dis.same(
            dis.no_imatch('This is A string', 's is a s'),
            ('FAIL', '', '{"have: This is A string","want: do not match the regular expression, case insensitive, s is a s"}')::dis.score,
            'No Insensive Match: FAIL due to case insensitivity'
        ),
        dis.same(
            dis.no_imatch('This is a string', '^This.*string$'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression, case insensitive, ^This.*string$"}')::dis.score,
            'No Insensive Match: FAIL with simple regex'
        ),
        dis.same(
            dis.no_imatch('This is a string', 'want'),
            ('OK', '', '{}')::dis.score,
            'No Insensive Match: OK with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_166_no_imatch() OWNER TO postgres;

--
-- Name: FUNCTION test_166_no_imatch(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_166_no_imatch() IS 'Ensure dis.no_imatch works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_170_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_170_type() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.type works as expected
-- plan: 5
-- module: assertions
-- submodule: type
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.type(3, 'integer'),
            ('OK', '', '{}')::dis.score,
            'Type: OK with integer'
        ),
        dis.same(
            dis.type('5'::text, 'integer'),
            ('FAIL', '', '{"have type: text","want type: integer"}')::dis.score,
            'Type: Fail with text vs integer'
        ),
        dis.same(
            dis.type(ARRAY[5], 'integer'),
            ('FAIL', '', '{"have type: integer[]","want type: integer"}')::dis.score,
            'Type: Fail with integer array vs integer'
        ),
        dis.same(
            dis.type('bob'::varchar, 'text'),
            ('FAIL', '', '{"have type: character varying","want type: text"}')::dis.score,
            'Type: Fail with varchar vs text'
        ),
        dis.same(
            dis.type(ARRAY['bob'], 'text'),
            ('FAIL', '', '{"have type: text[]","want type: text"}')::dis.score,
            'Type: Fail with text array vs text'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_170_type() OWNER TO postgres;

--
-- Name: FUNCTION test_170_type(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_170_type() IS 'Ensure dis.type works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_175_not_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_175_not_type() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_type works as expected
-- plan: 5
-- module: assertions
-- submodule: type
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_type(3, 'integer'),
            ('FAIL', '', '{"have type: integer","notwant type: integer"}')::dis.score,
            'Not Type: Fail with integer vs integer'
        ),
        dis.same(
            dis.not_type('5'::text, 'integer'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with text vs integer'
        ),
        dis.same(
            dis.not_type(ARRAY[5], 'integer'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with integer array vs integer'
        ),
        dis.same(
            dis.not_type('bob'::varchar, 'text'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with varchar vs text'
        ),
        dis.same(
            dis.not_type(ARRAY['bob'], 'text'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with text array vs text'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_175_not_type() OWNER TO postgres;

--
-- Name: FUNCTION test_175_not_type(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_175_not_type() IS 'Ensure dis.type works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_alpha(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_alpha() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example
-- submodule: basic
-- plan: 3
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(FALSE, 'Oops this will fail'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_alpha() OWNER TO postgres;

--
-- Name: FUNCTION test_alpha(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_alpha() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_beta(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_beta() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example
-- submodule: basic2
-- plan: 3
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_beta() OWNER TO postgres;

--
-- Name: FUNCTION test_beta(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_beta() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_delta(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_delta() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example2
-- submodule: larger
-- plan: 2
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_delta() OWNER TO postgres;

--
-- Name: FUNCTION test_delta(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_delta() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_epsilon(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_epsilon() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example2
-- submodule: simple
-- plan: 1
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_epsilon() OWNER TO postgres;

--
-- Name: FUNCTION test_epsilon(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_epsilon() IS 'Demo test (2012-03-15)';


--
-- Name: test_epsilon(); Type: ACL; Schema: dis_test; Owner: postgres
--

REVOKE ALL ON FUNCTION test_epsilon() FROM PUBLIC;
REVOKE ALL ON FUNCTION test_epsilon() FROM postgres;
GRANT ALL ON FUNCTION test_epsilon() TO postgres;
GRANT ALL ON FUNCTION test_epsilon() TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_gamma(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_gamma() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example
-- submodule: basic2
-- plan: 3
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_gamma() OWNER TO postgres;

--
-- Name: FUNCTION test_gamma(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_gamma() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_v1, pg_catalog;

--
-- Name: test_report_xml(text, text); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_report_xml(test_schema text, test_name text) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.test_report_xml(test_schema text, test_name text)
    Description:  Return the current results of the specified test as XML
    Affects:      nothing
    Arguments:    test_schema (text): schema of the test
                  test_name (text): name of the test
    Returns:      xml
*/
    SELECT xmlelement(name "Test",
        xmlelement(name "Schema", schema),
        xmlelement(name "Name", name),
        xmlelement(name "Module", module),
        xmlelement(name "SubModule", submodule),
        xmlelement(name "Status", status),
        xmlelement(name "Summary", summary),
        xmlelement(name "Statistics",
            xmlelement(name "Plan", plan),
            xmlelement(name "Run", tests),
            xmlelement(name "Successes", successes),
            xmlelement(name "Failures", failures)
        ),
        xmlelement(name "Assertions",
            (SELECT xmlagg(
                xmlelement(name "Assertion",
                    xmlelement(name "Status", status),
                    xmlelement(name "Message", message),
                    xmlelement(name "Details",
                        (SELECT xmlagg(
                            xmlelement(name "Detail", d)
                        ) FROM (SELECT unnest(detail) AS d) AS bar)
                    )
                )
            ) FROM (SELECT (unnest(detail)).*) AS foo)
        )
    ) FROM dis.result WHERE schema = $1 AND name = $2;
$_$;


ALTER FUNCTION dis_v1.test_report_xml(test_schema text, test_name text) OWNER TO postgres;

--
-- Name: FUNCTION test_report_xml(test_schema text, test_name text); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION test_report_xml(test_schema text, test_name text) IS 'Return the current results of the specified test as XML (2012-03-16)';


--
-- PostgreSQL database dump complete
--

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
-- Name: status_agg(text); Type: AGGREGATE; Schema: dis; Owner: postgres
--

CREATE AGGREGATE status_agg(text) (
    SFUNC = status_test,
    STYPE = text
);


ALTER AGGREGATE dis.status_agg(text) OWNER TO postgres;

--
-- Name: AGGREGATE status_agg(text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON AGGREGATE status_agg(text) IS 'Aggregate test status (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: result; Type: TABLE; Schema: dis; Owner: postgres; Tablespace: 
--

CREATE TABLE result (
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_by character varying DEFAULT "current_user"() NOT NULL,
    name text NOT NULL,
    schema text NOT NULL,
    module text,
    submodule text,
    plan integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'FAIL'::text NOT NULL,
    tests integer DEFAULT 0 NOT NULL,
    successes integer DEFAULT 0 NOT NULL,
    failures integer DEFAULT 0 NOT NULL,
    summary text NOT NULL,
    detail score[] DEFAULT '{}'::score[] NOT NULL
);


ALTER TABLE dis.result OWNER TO postgres;

--
-- Name: TABLE result; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TABLE result IS 'Results of test runs (2012-03-15)';


--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema);


--
-- Name: t_50_modified; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_50_modified BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE modified();


--
-- Name: t_90_history; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_90_history BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE dis_history.result_saver();


--
-- Name: result; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE result TO postgres;
GRANT SELECT,INSERT,DELETE ON TABLE result TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_history, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: result; Type: TABLE; Schema: dis_history; Owner: postgres; Tablespace: 
--

CREATE TABLE result (
    modified_at timestamp with time zone NOT NULL,
    modified_by character varying NOT NULL,
    name text NOT NULL,
    schema text NOT NULL,
    module text,
    submodule text,
    plan integer NOT NULL,
    status text NOT NULL,
    tests integer NOT NULL,
    successes integer NOT NULL,
    failures integer NOT NULL,
    summary text NOT NULL,
    detail dis.score[] NOT NULL
);


ALTER TABLE dis_history.result OWNER TO postgres;

--
-- Name: TABLE result; Type: COMMENT; Schema: dis_history; Owner: postgres
--

COMMENT ON TABLE result IS 'Results of all test runs (2012-03-15)';


--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis_history; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema, modified_at);


--
-- Name: result; Type: ACL; Schema: dis_history; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,REFERENCES,TRIGGER ON TABLE result TO postgres;
GRANT SELECT ON TABLE result TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: module_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW module_summary AS
    SELECT result.schema, result.module, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module;


ALTER TABLE dis.module_summary OWNER TO postgres;

--
-- Name: VIEW module_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW module_summary IS 'DR: Summary of test results by schema module (2012-03-16)';


--
-- Name: module_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE module_summary FROM PUBLIC;
REVOKE ALL ON TABLE module_summary FROM postgres;
GRANT ALL ON TABLE module_summary TO postgres;
GRANT SELECT ON TABLE module_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: schema_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW schema_summary AS
    SELECT result.schema, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema;


ALTER TABLE dis.schema_summary OWNER TO postgres;

--
-- Name: VIEW schema_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW schema_summary IS 'DR: Summary of schema test results (2012-03-16)';


--
-- Name: schema_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE schema_summary FROM PUBLIC;
REVOKE ALL ON TABLE schema_summary FROM postgres;
GRANT ALL ON TABLE schema_summary TO postgres;
GRANT SELECT ON TABLE schema_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: submodule_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW submodule_summary AS
    SELECT result.schema, result.module, result.submodule, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module, result.submodule;


ALTER TABLE dis.submodule_summary OWNER TO postgres;

--
-- Name: VIEW submodule_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW submodule_summary IS 'DR: Summary of test results by schema module submodule (2012-03-16)';


--
-- Name: submodule_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE submodule_summary FROM PUBLIC;
REVOKE ALL ON TABLE submodule_summary FROM postgres;
GRANT ALL ON TABLE submodule_summary TO postgres;
GRANT SELECT ON TABLE submodule_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: test; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW test AS
    SELECT pg_proc.proname AS name, pg_namespace.nspname AS schema, COALESCE("substring"(pg_proc.prosrc, '--\\s+module[:]\\s+(\\S+)'::text), ''::text) AS module, COALESCE("substring"(pg_proc.prosrc, '--\\s+submodule[:]\\s+(\\S+)'::text), ''::text) AS submodule, COALESCE(("substring"(pg_proc.prosrc, '--\\s+plan[:]\\s+(\\d+)'::text))::integer, 0) AS plan FROM (pg_namespace LEFT JOIN pg_proc ON ((pg_proc.pronamespace = pg_namespace.oid))) WHERE ((pg_namespace.nspname ~ '_test$'::text) AND (pg_proc.proname ~ '^test_'::text));


ALTER TABLE dis.test OWNER TO postgres;

--
-- Name: VIEW test; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW test IS 'Tests that can be executed (2012-03-15)';


--
-- Name: test; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE test FROM PUBLIC;
REVOKE ALL ON TABLE test FROM postgres;
GRANT ALL ON TABLE test TO postgres;
GRANT SELECT ON TABLE test TO PUBLIC;


--
-- PostgreSQL database dump complete
--



COMMIT;
