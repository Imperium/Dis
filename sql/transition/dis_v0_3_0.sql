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

SET search_path = dis, pg_catalog;

--
-- Name: schema_summary; Type: VIEW; Schema: dis; Owner: postgres
--

DROP VIEW schema_summary;
CREATE OR REPLACE VIEW schema_summary AS
    SELECT result.schema, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema;


ALTER TABLE dis.schema_summary OWNER TO postgres;

--
-- Name: VIEW schema_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW schema_summary IS 'Summary of schema test results (2012-03-16)';


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
-- Name: module_summary; Type: VIEW; Schema: dis; Owner: postgres
--

DROP VIEW module_summary;
CREATE OR REPLACE VIEW module_summary AS
    SELECT result.schema, result.module, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module;


ALTER TABLE dis.module_summary OWNER TO postgres;

--
-- Name: VIEW module_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW module_summary IS 'Summary of test results by schema module (2012-03-16)';


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
-- Name: submodule_summary; Type: VIEW; Schema: dis; Owner: postgres
--

DROP VIEW submodule_summary;
CREATE OR REPLACE VIEW submodule_summary AS
    SELECT result.schema, result.module, result.submodule, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module, result.submodule;


ALTER TABLE dis.submodule_summary OWNER TO postgres;

--
-- Name: VIEW submodule_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW submodule_summary IS 'Summary of test results by schema module submodule (2012-03-16)';


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

COMMENT ON FUNCTION fail(message text) IS 'Return a fail score (2012-03-21)';


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

COMMENT ON FUNCTION greater(have anyelement, want anyelement, message text) IS 'Test if have is greater than want (2012-03-21)';


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

COMMENT ON FUNCTION greater_equal(have anyelement, want anyelement, message text) IS 'Test if have is greater than or equal to want (2012-03-21)';


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

COMMENT ON FUNCTION imatch(have text, regex text, message text) IS 'Test if have matches regex, case insensitive (2012-03-23)';


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

COMMENT ON FUNCTION in_array(have anyarray, want anyarray, message text) IS 'Test to see if have elements are contained by want (2012-03-23)';


--
-- Name: FUNCTION in_array(have anynonarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION in_array(have anynonarray, want anyarray, message text) IS 'Test to see if have is contained by want (2012-03-23)';


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

COMMENT ON FUNCTION less(have anyelement, want anyelement, message text) IS 'Test if have is less than want (2012-03-21)';


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

COMMENT ON FUNCTION less_equal(have anyelement, want anyelement, message text) IS 'Test if have is less than or equal to want (2012-03-21)';


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

COMMENT ON FUNCTION match(have text, regex text, message text) IS 'Test if have matches regex (2012-03-23)';


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

COMMENT ON FUNCTION no_imatch(have text, regex text, message text) IS 'Test if have does not match regex, case insensitive (2012-03-23)';


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

COMMENT ON FUNCTION no_match(have text, regex text, message text) IS 'Test if have does not match regex (2012-03-23)';


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

COMMENT ON FUNCTION not_contains(have anyarray, notwant anyarray, message text) IS 'Test to see if have does not contain the array of objects in notwant (2012-03-23)';


--
-- Name: FUNCTION not_contains(have anyarray, notwant anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_contains(have anyarray, notwant anynonarray, message text) IS 'Test to see if have does not contain notwant (2012-03-23)';


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

COMMENT ON FUNCTION not_in_array(have anyarray, notwant anyarray, message text) IS 'Test to see if have elements are not contained by notwant (2012-03-23)';


--
-- Name: FUNCTION not_in_array(have anynonarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anynonarray, notwant anyarray, message text) IS 'Test to see if have is not contained by notwant (2012-03-23)';


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

COMMENT ON FUNCTION not_type(have anyelement, notwant regtype, message text) IS 'Check if have is not the provided regtype (2012-03-20)';


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

COMMENT ON FUNCTION ok(message text) IS 'Return an ok score (2012-03-21)';


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

COMMENT ON FUNCTION run_test(test_schema text, test_name text) IS 'Run a test and record the results (2012-03-15)';


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
        DELETE FROM dis.result WHERE schema = test_schema AND module = test_module;
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema AND module = test_module
            ORDER BY schema, module, submodule, name;
    ELSE
        DELETE FROM dis.result WHERE schema = test_schema AND module = test_module AND submodule = test_submodule;
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

COMMENT ON FUNCTION test_wrapper(schema text, name text) IS 'Test wrapper to ensure an exception is thrown (2012-03-15)';


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

COMMENT ON FUNCTION todo(message text) IS 'Placdholder for a real test to be added later (2012-03-15)';


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

COMMENT ON FUNCTION type(have anyelement, want regtype, message text) IS 'Check if have is the provided regtype (2012-03-20)';


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
-- Name: module_summary_xml(text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION module_summary_xml(schema text, module text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.module_summary_xml(schema text, module text, detail boolean DEFAULT FALSE)
    Description:  XML summary of the schema/module requested
    Affects:      nothing
    Arguments:    schema (text): schema name
                  module (text): module name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "Module",
        xmlelement(name "Name", s.module),
        xmlelement(name "Schema", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $3 IS TRUE THEN
            xmlelement(name "SubModules",
                (SELECT xmlagg(
                    dis_v1.submodule_summary_xml(a.schema, a.module, a.submodule, FALSE)
                ) FROM (SELECT schema, module, submodule FROM dis.submodule_summary WHERE schema = $1 AND module = $2 ORDER by submodule) AS a)
            )
            ELSE NULL
        END
    ) FROM dis.module_summary AS s WHERE s.schema = $1 AND s.module = $2;
$_$;


ALTER FUNCTION dis_v1.module_summary_xml(schema text, module text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION module_summary_xml(schema text, module text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION module_summary_xml(schema text, module text, detail boolean) IS 'XML summary of the schema/module requested (2012-04-01)';


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
-- Name: run_tests_xml(text, text, text); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_tests_xml(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS xml
    LANGUAGE sql
    AS $_$
/*  Function:     dis_v1.run_tests_xml(schema text DEFAULT NULL, module text DEFAULT NULL, submodule text DEFAULT NULL)
    Description:  Run the specified tests
    Affects:      Executes the tests in the specified schema/module/submodule
    Arguments:    schema (text): (Optional) Limit to this schema
                  module (text): (Optional) Limit to this module
                  submodule (text): (Optional) Limit to this submodule
    Returns:      xml
*/
    SELECT xmlelement(name "Successful", dis.run_tests($1, $2, $3));
$_$;


ALTER FUNCTION dis_v1.run_tests_xml(schema text, module text, submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests_xml(schema text, module text, submodule text); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION run_tests_xml(schema text, module text, submodule text) IS 'Run the specified tests (2012-04-08)';


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
-- Name: schema_summary_xml(text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION schema_summary_xml(schema text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.schema_summary_xml(schema text, detail boolean DEFAULT FALSE)
    Description:  XML summary of schema results
    Affects:      nothing
    Arguments:    schema (text): schema name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "Schema",
        xmlelement(name "Name", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $2 IS TRUE THEN
            xmlelement(name "Module", 
                (SELECT xmlagg(
                    dis_v1.module_summary_xml(foo.schema, foo.module, FALSE)
                ) FROM (SELECT schema, module FROM dis.module_summary AS t WHERE t.schema = $1 ORDER BY module) AS foo)
            )
            ELSE NULL
        END
    ) FROM dis.schema_summary AS s WHERE schema = $1;
$_$;


ALTER FUNCTION dis_v1.schema_summary_xml(schema text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION schema_summary_xml(schema text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION schema_summary_xml(schema text, detail boolean) IS 'XML summary of schema results (2012-04-01)';


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
-- Name: schemata_summary_xml(); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION schemata_summary_xml() RETURNS xml
    LANGUAGE sql STABLE
    AS $$
/*  Function:     dis_v1.schemata_summary_xml()
    Description:  Summary of all schemata test results
    Affects:      nothing
    Arguments:    none
    Returns:      XML
*/
    SELECT xmlelement(name "Schemata",
        (SELECT xmlagg(
            dis_v1.schema_summary_xml(schema, FALSE)
        ) FROM (SELECT schema FROM dis.schema_summary ORDER BY schema) as s)
    );
$$;


ALTER FUNCTION dis_v1.schemata_summary_xml() OWNER TO postgres;

--
-- Name: FUNCTION schemata_summary_xml(); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION schemata_summary_xml() IS 'Summary of all schemata test results (2012-04-08)';


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
-- Name: submodule_summary_xml(text, text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false)
    Description:  XML summary of the schema/module/submodule requested
    Affects:      nothing
    Arguments:    schema (text): schema name
                  module (text): module name
                  submodule (text): submodule name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "SubModule", 
        xmlelement(name "SubModule", s.submodule),
        xmlelement(name "Module", s.module),
        xmlelement(name "Schema", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $4 IS TRUE THEN
            xmlelement(name "Tests", 
                (SELECT xmlagg(
                    dis_v1.test_report_xml(foo.schema, foo.name, FALSE)
                ) FROM (SELECT schema, name FROM dis.test AS t WHERE t.schema = $1 AND t.module = $2 AND t.submodule = $3 ORDER BY name) AS foo)
            )
            ELSE NULL
        END
    ) FROM dis.submodule_summary AS s WHERE s.schema = $1 AND s.module = $2 AND s.submodule = $3;
$_$;


ALTER FUNCTION dis_v1.submodule_summary_xml(schema text, module text, submodule text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean) IS 'XML summary of the schema/module/submodule requested (2012-04-01)';


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
-- Name: test_report_xml(text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_report_xml(test_schema text, test_name text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.test_report_xml(test_schema text,  test_name text, detail boolean DEFAULT FALSE)
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
        CASE WHEN $3 IS TRUE THEN
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
            ELSE NULL
        END
    ) FROM dis.result WHERE schema = $1 AND name = $2;
$_$;


ALTER FUNCTION dis_v1.test_report_xml(test_schema text, test_name text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION test_report_xml(test_schema text, test_name text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION test_report_xml(test_schema text, test_name text, detail boolean) IS 'Return the current results of the specified test as XML (2012-03-16)';


--
-- PostgreSQL database dump complete
--



COMMIT;
