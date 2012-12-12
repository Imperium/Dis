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
-- Name: dis_example_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_example_test;


ALTER SCHEMA dis_example_test OWNER TO postgres;

--
-- Name: dis_history; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_history;


ALTER SCHEMA dis_history OWNER TO postgres;

--
-- Name: dis_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_test;


ALTER SCHEMA dis_test OWNER TO postgres;

--
-- Name: dis_v1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_v1;


ALTER SCHEMA dis_v1 OWNER TO postgres;

SET search_path = dis, pg_catalog;

--
-- Name: mold; Type: TYPE; Schema: dis; Owner: postgres
--

CREATE TYPE mold AS (
	value text,
	type regtype
);


ALTER TYPE dis.mold OWNER TO postgres;

--
-- Name: TYPE mold; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TYPE mold IS 'Encapsulation of a value cast to text and the original regtype (2012-04-10)';


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
-- Name: _count(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION _count(call text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis._count(call text)
    Description:  Report the number of rows returned by the provided query
    Affects:      nothing, unless the query does something
    Arguments:    call (text): query to execute
    Returns:      integer: count of results (null if error)
*/
DECLARE
    _count      integer;
BEGIN
    EXECUTE 'SELECT count(*) FROM (' || call || ') AS foo' INTO _count;
    RETURN _count;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$;


ALTER FUNCTION dis._count(call text) OWNER TO postgres;

--
-- Name: FUNCTION _count(call text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION _count(call text) IS 'Report the number of rows returned by the provided query (2012-04-14)';


--
-- Name: assert(boolean, text, text[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION assert(assertion boolean, message text DEFAULT ''::text, detail text[] DEFAULT '{}'::text[]) RETURNS score
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
-- Name: compare(anyelement, text, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION compare(have anyelement, operator text, against anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.compare(have anyelement, operator text, against anyelement, message text DEFAULT '')
    Description:  Test "have" vs "against" using "operator"
                  *NOTE* have and against must be of the same type
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  operator (text): Comparison operator
                  against (anyelement): Value to compare against
                  message (text): Descriptive message (Optional)
    Returns:      dis.score
*/
DECLARE
    _returns        boolean;
    _score          dis.score;
BEGIN
    EXECUTE 'SELECT ' || COALESCE(quote_literal( have ), 'NULL') || '::' || pg_typeof(have) || ' '
                      || operator || ' '
                      || COALESCE(quote_literal( against ), 'NULL') || '::' || pg_typeof(against)
        INTO _returns;
    _score := dis.assert(
        _returns,
        message,
        ARRAY[
            ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
            ('operator: ' || operator),
            ('against: ' || COALESCE(against::text, 'NULL') || ' (' || pg_typeof(against) || ')')
        ]
    );
    RETURN _score;
EXCEPTION
    WHEN OTHERS THEN
      _score := dis.assert(
          _returns,
          message,
          ARRAY[
              ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
              ('operator: ' || operator),
              ('against: ' || COALESCE(against::text, 'NULL') || ' (' || pg_typeof(against) || ')'),
              ('error: ' || SQLSTATE || ' -- ' || SQLERRM)
          ]
      );
      RETURN _score;
END;
$$;


ALTER FUNCTION dis.compare(have anyelement, operator text, against anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION compare(have anyelement, operator text, against anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against anyelement, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


--
-- Name: compare(anyelement, text, mold, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION compare(have anyelement, operator text, against mold, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.compare_mold(have anyelement, operator text, against mold, message text DEFAULT '')
    Description:  Test "have" vs "against" using "operator"
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  operator (text): Comparison operator
                  against (dis.mold): Molded value to compare against
                  message (text): Descriptive message (Optional)
    Returns:      score
*/
DECLARE
    _returns        boolean;
    _score          dis.score;
BEGIN
    EXECUTE 'SELECT ' || COALESCE(quote_literal( have ), 'NULL') || '::' || pg_typeof(have) || ' '
                      || operator || ' '
                      || COALESCE(quote_literal( against.value ), 'NULL') || '::' || against.type
        INTO _returns;
    _score := dis.assert(
        _returns,
        message,
        ARRAY[
            ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
            ('operator: ' || operator),
            ('against: ' || COALESCE(against.value, 'NULL') || ' (' || against.type || ')')
        ]
    );
    RETURN _score;
EXCEPTION
    WHEN OTHERS THEN
      _score := dis.assert(
          _returns,
          message,
          ARRAY[
              ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
              ('operator: ' || operator),
              ('against: ' || COALESCE(against.value, 'NULL') || ' (' || against.type || ')'),
              ('error: ' || SQLSTATE || ' -- ' || SQLERRM)
          ]
      );
      RETURN _score;
END;
$$;


ALTER FUNCTION dis.compare(have anyelement, operator text, against mold, message text) OWNER TO postgres;

--
-- Name: FUNCTION compare(have anyelement, operator text, against mold, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against mold, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


--
-- Name: contains(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION contains(have anyarray, want anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION contains(have anyarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION contains(have anyarray, want anyarray, message text) IS 'Test to see if have contains the array of objects in want (2012-03-23)';


--
-- Name: contains(anyarray, anynonarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION contains(have anyarray, want anynonarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION contains(have anyarray, want anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION contains(have anyarray, want anynonarray, message text) IS 'Test to see if have contains want (2012-03-23)';


--
-- Name: fail(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION fail(message text DEFAULT ''::text) RETURNS score
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
-- Name: greater(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION greater(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: greater_equal(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION greater_equal(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: has_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION has_result(call text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.has_result(call text, message text DEFAULT '')
    Description:  Test if the provided query returns results
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
        _count > 0,
        message,
        ARRAY[
            ('call: ' || call),
            ('have: ' || COALESCE(_count || ' results', 'failed to execute')),
            ('want: result count greater than zero')
        ]
    );
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.has_result(call text, message text) OWNER TO postgres;

--
-- Name: FUNCTION has_result(call text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION has_result(call text, message text) IS 'Test if the provided query returns results (2012-04-14)';


--
-- Name: imatch(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION imatch(have text, regex text, message text DEFAULT ''::text) RETURNS score
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
-- Name: in_array(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION in_array(have anyarray, want anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION in_array(have anyarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION in_array(have anyarray, want anyarray, message text) IS 'Test to see if have elements are contained by want (2012-03-23)';


--
-- Name: in_array(anynonarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION in_array(have anynonarray, want anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION in_array(have anynonarray, want anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION in_array(have anynonarray, want anyarray, message text) IS 'Test to see if have is contained by want (2012-03-23)';


--
-- Name: less(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION less(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: less_equal(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION less_equal(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: match(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION match(have text, regex text, message text DEFAULT ''::text) RETURNS score
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
-- Name: modified(); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION modified() RETURNS trigger
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
-- Name: mold(anyelement); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION mold(value anyelement) RETURNS mold
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.mold(value anyelement)
    Description:  Convert value to a dis.mold
    Affects:      nothing
    Arguments:    value (anyelement): value to cast into a dis.mold
    Returns:      dis.mold
*/
DECLARE
    _mold       dis.mold;
    _distinct   boolean;
BEGIN
    _mold := (
        value::text,
        pg_typeof(value)
    )::dis.mold;

    BEGIN
        EXECUTE 'SELECT ' || COALESCE(quote_literal( value ), 'NULL') || '::' || pg_typeof(value)
                          || ' IS DISTINCT FROM '
                          || COALESCE(quote_literal( _mold.value ), 'NULL') || '::' || _mold.type
            INTO _distinct;
    EXCEPTION
        WHEN OTHERS THEN RAISE EXCEPTION 'Unable to properly mold value "%::%"', _mold.value, _mold.type;
    END;

    IF _distinct IS FALSE THEN
        RETURN _mold;
    END IF;
    RAISE EXCEPTION 'Unable to properly mold value "%::%"', _mold.value, _mold.type;
END;
$$;


ALTER FUNCTION dis.mold(value anyelement) OWNER TO postgres;

--
-- Name: FUNCTION mold(value anyelement); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION mold(value anyelement) IS 'Convert value to a dis.mold (2012-04-10)';


--
-- Name: no_imatch(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION no_imatch(have text, regex text, message text DEFAULT ''::text) RETURNS score
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
-- Name: no_match(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION no_match(have text, regex text, message text DEFAULT ''::text) RETURNS score
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
-- Name: no_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION no_result(call text, message text DEFAULT ''::text) RETURNS score
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
-- Name: not_contains(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_contains(have anyarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION not_contains(have anyarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_contains(have anyarray, notwant anyarray, message text) IS 'Test to see if have does not contain the array of objects in notwant (2012-03-23)';


--
-- Name: not_contains(anyarray, anynonarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_contains(have anyarray, notwant anynonarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION not_contains(have anyarray, notwant anynonarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_contains(have anyarray, notwant anynonarray, message text) IS 'Test to see if have does not contain notwant (2012-03-23)';


--
-- Name: not_in_array(anyarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_in_array(have anyarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION not_in_array(have anyarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anyarray, notwant anyarray, message text) IS 'Test to see if have elements are not contained by notwant (2012-03-23)';


--
-- Name: not_in_array(anynonarray, anyarray, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_in_array(have anynonarray, notwant anyarray, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION not_in_array(have anynonarray, notwant anyarray, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_in_array(have anynonarray, notwant anyarray, message text) IS 'Test to see if have is not contained by notwant (2012-03-23)';


--
-- Name: not_raises(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_raises(call text, notwant text DEFAULT NULL::text, message text DEFAULT ''::text) RETURNS score
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
-- Name: not_same(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_same(have anyelement, notwant anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: not_type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION not_type(have anyelement, notwant regtype, message text DEFAULT ''::text) RETURNS score
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
-- Name: ok(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION ok(message text DEFAULT ''::text) RETURNS score
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
-- Name: one_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION one_result(call text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis.one_result(call text, message text DEFAULT '')
    Description:  Test if the provided query returns one result
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
        _count = 1,
        message,
        ARRAY[
            ('call: ' || call),
            ('have: ' || COALESCE(_count || ' results', 'failed to execute')),
            ('want: one result')
        ]
    );
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.one_result(call text, message text) OWNER TO postgres;

--
-- Name: FUNCTION one_result(call text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION one_result(call text, message text) IS 'Test if the provided query returns one result (2012-04-14)';


--
-- Name: raises(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION raises(call text, want text DEFAULT NULL::text, message text DEFAULT ''::text) RETURNS score
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
-- Name: run_test(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION run_test(schema text, name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.run_test(schema text, name text)
    Description:  Run a test and record the results
    Affects:      
    Arguments:    
    Returns:      boolean
*/
DECLARE
    _schema     text        := schema;
    _name       text        := name;
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
    IF _schema !~* '_test$' THEN
        _schema := _schema || '_test';
    END IF;
    IF _name !~* '^test_' THEN
        _name := 'test_' || _name;
    END IF;
    SELECT * INTO _test FROM dis.test AS test WHERE test.schema = _schema AND test.name = _name;
    IF _test.name IS NULL THEN
        RAISE EXCEPTION 'Test %.% does not exist', _schema, _name;
    END IF;
    DELETE FROM dis.result AS r WHERE r.schema = _schema AND r.name = _name;

    BEGIN
        PERFORM dis.test_wrapper(_schema, _name);
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
                VALUES (_name, _schema, _test.module, _test.submodule, _test.plan, _status, _count, _success, _failure, _summary, _scores);
    END;
    RETURN TRUE;
END;
$_$;


ALTER FUNCTION dis.run_test(schema text, name text) OWNER TO postgres;

--
-- Name: FUNCTION run_test(schema text, name text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_test(schema text, name text) IS 'Run a test and record the results (2012-03-15)';


--
-- Name: run_tests(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION run_tests(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.run_tests(schema text, module text, submodule text)
    Description:  Run the specified tests
    Affects:      Executes
    Arguments:    schema (text): (Optional) Limit run to tests in this schema
                  module (text): (Optional) Limit run to tests in this module
                  submodule (text): (Optional) Limit run to tests in this submodule
    Returns:      boolean
*/
DECLARE
    _schema     text := schema;
    _module     text := module;
    _submodule  text := submodule;
BEGIN
    IF _schema !~* '_test$' THEN
        _schema := _schema || '_test';
    END IF;
    IF _schema IS NULL THEN
        DELETE FROM dis.result AS r;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSEIF module IS NULL THEN
        DELETE FROM dis.result AS r WHERE r.schema = _schema;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSEIF submodule IS NULL THEN
        DELETE FROM dis.result AS r WHERE r.schema = _schema AND r.module = _module;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema AND test.module = _module
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSE
        DELETE FROM dis.result AS r WHERE r.schema = _schema AND r.module = _module AND r.submodule = _submodule;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema AND test.module = _module AND test.submodule = _submodule
            ORDER BY test.schema, test.module, test.submodule, test.name;
    END IF;
    RETURN TRUE;
END;
$_$;


ALTER FUNCTION dis.run_tests(schema text, module text, submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests(schema text, module text, submodule text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_tests(schema text, module text, submodule text) IS 'Run the specified tests (2012-03-16)';


--
-- Name: same(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION same(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: skip(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION skip(message text DEFAULT ''::text) RETURNS score
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
-- Name: status_test(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION status_test(initial_value text, next_value text) RETURNS text
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
-- Name: tally(score[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION tally(tallies score[]) RETURNS void
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
-- Name: test_wrapper(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION test_wrapper(schema text, name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.test_wrapper(schema text, name text)
    Description:  Test wrapper to ensure an exception is thrown
    Affects:      Executes provided function
    Arguments:    schema (text): schema of the function
                  name (text): name of the function
    Returns:      void
*/
DECLARE
    _schema     text := schema;
    _name       text := name;
BEGIN
    IF _schema !~* '_test$' THEN
        _schema := _schema || '_test';
    END IF;
    IF _name !~* '^test_' THEN
        _name := 'test_' || _name;
    END IF;
    EXECUTE 'SELECT ' || quote_ident(_schema) || '.' || quote_ident(_name) || '()';
    RAISE EXCEPTION '[NONE][0][0][0]{}';
END;
$_$;


ALTER FUNCTION dis.test_wrapper(schema text, name text) OWNER TO postgres;

--
-- Name: FUNCTION test_wrapper(schema text, name text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION test_wrapper(schema text, name text) IS 'Test wrapper to ensure an exception is thrown (2012-03-15)';


--
-- Name: todo(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION todo(message text DEFAULT ''::text) RETURNS score
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
-- Name: type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE FUNCTION type(have anyelement, want regtype, message text DEFAULT ''::text) RETURNS score
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


SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_alpha(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE FUNCTION test_alpha() RETURNS void
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


ALTER FUNCTION dis_example_test.test_alpha() OWNER TO postgres;

--
-- Name: FUNCTION test_alpha(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_alpha() IS 'Demo test (2012-03-15)';


--
-- Name: test_beta(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE FUNCTION test_beta() RETURNS void
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


ALTER FUNCTION dis_example_test.test_beta() OWNER TO postgres;

--
-- Name: FUNCTION test_beta(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_beta() IS 'Demo test (2012-03-15)';


--
-- Name: test_delta(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE FUNCTION test_delta() RETURNS void
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


ALTER FUNCTION dis_example_test.test_delta() OWNER TO postgres;

--
-- Name: FUNCTION test_delta(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_delta() IS 'Demo test (2012-03-15)';


--
-- Name: test_epsilon(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE FUNCTION test_epsilon() RETURNS void
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


ALTER FUNCTION dis_example_test.test_epsilon() OWNER TO postgres;

--
-- Name: FUNCTION test_epsilon(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_epsilon() IS 'Demo test (2012-03-15)';


--
-- Name: test_gamma(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE FUNCTION test_gamma() RETURNS void
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


ALTER FUNCTION dis_example_test.test_gamma() OWNER TO postgres;

--
-- Name: FUNCTION test_gamma(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_gamma() IS 'Demo test (2012-03-15)';


SET search_path = dis_history, pg_catalog;

--
-- Name: result_saver(); Type: FUNCTION; Schema: dis_history; Owner: postgres
--

CREATE FUNCTION result_saver() RETURNS trigger
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


SET search_path = dis_test, pg_catalog;

--
-- Name: test_070__count(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_070__count() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis._count operates as expected
-- plan: 3
-- module: helpers
-- submodule: execute
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis._count('SELECT 5'),
            1,
            '_count: One result'
        ),
        dis.same(
            dis._count('SELECT * FROM dis.test limit 0'),
            0,
            '_count: no result'
        ),
        dis.same(
            dis._count('SELECT * WHERE'),
            null::integer,
            '_count: execution failure'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_070__count() OWNER TO postgres;

--
-- Name: FUNCTION test_070__count(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_070__count() IS 'Ensure dis._count operates as expected (2012-04-14)';


--
-- Name: test_120_ok(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_120_ok() RETURNS void
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
-- Name: test_122_fail(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_122_fail() RETURNS void
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
-- Name: test_124_todo(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_124_todo() RETURNS void
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
-- Name: test_126_skip(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_126_skip() RETURNS void
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
-- Name: test_130_same(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_130_same() RETURNS void
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
-- Name: test_135_not_same(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_135_not_same() RETURNS void
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
-- Name: test_140_greater(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_140_greater() RETURNS void
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
-- Name: test_142_greater_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_142_greater_equal() RETURNS void
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
-- Name: test_144_less(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_144_less() RETURNS void
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
-- Name: test_146_less_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_146_less_equal() RETURNS void
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
-- Name: test_150_contains(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_150_contains() RETURNS void
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
-- Name: test_152_not_contains(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_152_not_contains() RETURNS void
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
-- Name: test_154_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_154_in_array() RETURNS void
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
-- Name: test_156_not_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_156_not_in_array() RETURNS void
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
-- Name: test_160_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_160_match() RETURNS void
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
-- Name: test_162_no_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_162_no_match() RETURNS void
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
-- Name: test_164_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_164_imatch() RETURNS void
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
-- Name: test_166_no_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_166_no_imatch() RETURNS void
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
-- Name: test_170_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_170_type() RETURNS void
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
-- Name: test_175_not_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_175_not_type() RETURNS void
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
-- Name: test_180_compare(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_180_compare() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.compare (non-mold version) works as expected
-- plan: 4
-- module: assertions
-- submodule: compare
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.compare(5, '>', 4),
            ('OK', '', '{}')::dis.score,
            'Compare: OK 5 > 4'
        ),
        dis.same(
            dis.compare(5, '<', 4),
            ('FAIL', '', '{"have: 5 (integer)","operator: <","against: 4 (integer)"}')::dis.score,
            'Compare: FAIL 5 < 4'
        ),
        dis.same(
            dis.compare('10.0.0.0/8'::inet,'>>=','10.0.0.1/32'::inet),
            ('OK', '', '{}')::dis.score,
            'Compare: OK  10.0.0.0/8 >>= 10.0.0.1/32'
        ),
        dis.same(
            dis.compare(5, '<@', 4),
            ('FAIL', '', '{"have: 5 (integer)","operator: <@","against: 4 (integer)","error: 42883 -- operator does not exist: integer <@ integer"}')::dis.score,
            'Compare: FAIL on unknown operator'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_180_compare() OWNER TO postgres;

--
-- Name: FUNCTION test_180_compare(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_180_compare() IS 'Ensure dis.compare (non-mold version) works as expected (2012-04-10)';


--
-- Name: test_185_compare(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_185_compare() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.compare (mold version) works as expected
-- plan: 4
-- module: assertions
-- submodule: compare
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.compare(5, '>', dis.mold(4.0)),
            ('OK', '', '{}')::dis.score,
            'Compare: OK 5 > 4'
        ),
        dis.same(
            dis.compare(5, '<', dis.mold(4.5)),
            ('FAIL', '', '{"have: 5 (integer)","operator: <","against: 4.5 (numeric)"}')::dis.score,
            'Compare: FAIL 5 < 4.5'
        ),
        dis.same(
            dis.compare('10.0.0.0/8'::cidr,'>>=',dis.mold('10.0.0.1/32'::inet)),
            ('OK', '', '{}')::dis.score,
            'Compare: OK  10.0.0.0/8::cidr >>= 10.0.0.1/32::inet'
        ),
        dis.same(
            dis.compare(5, '>>=', dis.mold(4)),
            ('FAIL', '', '{"have: 5 (integer)","operator: >>=","against: 4 (integer)","error: 42883 -- operator does not exist: integer >>= integer"}')::dis.score,
            'Compare: FAIL on unknown operator'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_185_compare() OWNER TO postgres;

--
-- Name: FUNCTION test_185_compare(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_185_compare() IS 'Ensure dis.compare (mold version) works as expected (2012-04-10)';


--
-- Name: test_220_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_220_raises() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.raises works as expected
-- plan: 6
-- module: assertions
-- submodule: raises
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.raises('SELECT 5 / 0'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on any error'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', '22012'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on SQLSTATE 22012'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', 'division by zero'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on SQLERRM division by zero'
        ),
        dis.same(
            dis.raises('select 5 >>= 0', 'division by zero'),
            ('FAIL', '', '{"call: select 5 >>= 0","have: 42883/operator does not exist: integer >>= integer (SQLSTATE/SQLERRM)","want: division by zero (SQLERRM)"}')::dis.score,
            'Raises: FAIL on wrong SQLERRM'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', '42883'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","want: 42883 (SQLSTATE)"}')::dis.score,
            'Raises: FAIL on wrong SQLSTATE'
        ),
        dis.same(
            dis.raises('SELECT 5'),
            ('FAIL', '', '{"call: SELECT 5","have: no error raised","want: Any Error"}')::dis.score,
            'Raises: FAIL on no error raised'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_220_raises() OWNER TO postgres;

--
-- Name: FUNCTION test_220_raises(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_220_raises() IS 'Ensure dis.raises works as expected (2012-04-11)';


--
-- Name: test_225_not_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_225_not_raises() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_raises works as expected
-- plan: 6
-- module: assertions
-- submodule: raises
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_raises('SELECT 5'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on no error'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', '42883'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on different SQLSTATE'
        ),
        dis.same(
            dis.not_raises('select 5 >>= 0', 'division by zero'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on different SQLERRM'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', 'division by zero'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: division by zero (SQLERRM)"}')::dis.score,
            'Not Raises: FAIL on matching SQLERRM'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', '22012'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: 22012 (SQLSTATE)"}')::dis.score,
            'Not Raises: FAIL on wrong SQLSTATE'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: Any Error"}')::dis.score,
            'Not Raises: FAIL on no error raised'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_225_not_raises() OWNER TO postgres;

--
-- Name: FUNCTION test_225_not_raises(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_225_not_raises() IS 'Ensure dis.not_raises works as expected (2012-04-11)';


--
-- Name: test_240_no_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_240_no_result() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.no_result operates as expected
-- plan: 3
-- module: assertions
-- submodule: result
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.no_result('SELECT * from dis.test WHERE schema = ''x'''),
            ('OK', '', '{}')::dis.score,
            'No Result: OK because no results'
        ),
        dis.same(
            dis.no_result('SELECT 5'),
            ('FAIL', '', '{"call: SELECT 5","have: 1 results","want: no results"}')::dis.score,
            'No Result: FAIL because has result'
        ),
        dis.same(
            dis.no_result('SELECT * WHERE'),
            ('FAIL', '', '{"call: SELECT * WHERE","have: failed to execute","want: no results"}')::dis.score,
            'No Result: FAIL because of execution failure'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_240_no_result() OWNER TO postgres;

--
-- Name: FUNCTION test_240_no_result(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_240_no_result() IS 'Ensure dis.no_result operates as expected (2012-04-14)';


--
-- Name: test_242_has_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_242_has_result() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.has_result operates as expected
-- plan: 3
-- module: assertions
-- submodule: result
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.has_result('SELECT * from dis.test WHERE schema = ''x'''),
            ('FAIL', '', '{"call: SELECT * from dis.test WHERE schema = ''x''","have: 0 results","want: result count greater than zero"}')::dis.score,
            'Has Result: FAIL because no results'
        ),
        dis.same(
            dis.has_result('SELECT 5'),
            ('OK', '', '{}')::dis.score,
            'Has Result: OK because has result'
        ),
        dis.same(
            dis.has_result('SELECT * WHERE'),
            ('FAIL', '', '{"call: SELECT * WHERE","have: failed to execute","want: result count greater than zero"}')::dis.score,
            'Has Result: FAIL because of execution failure'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_242_has_result() OWNER TO postgres;

--
-- Name: FUNCTION test_242_has_result(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_242_has_result() IS 'Ensure dis.has_result operates as expected (2012-04-14)';


--
-- Name: test_244_one_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE FUNCTION test_244_one_result() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.one_result operates as expected
-- plan: 4
-- module: assertions
-- submodule: result
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.one_result('SELECT * from dis.test WHERE schema = ''x'''),
            ('FAIL', '', '{"call: SELECT * from dis.test WHERE schema = ''x''","have: 0 results","want: one result"}')::dis.score,
            'One Result: FAIL because no results'
        ),
        dis.same(
            dis.one_result('SELECT 5'),
            ('OK', '', '{}')::dis.score,
            'One Result: OK because has single result'
        ),
        dis.same(
            dis.one_result('SELECT * from dis.test limit 4'),
            ('FAIL', '', '{"call: SELECT * from dis.test limit 4","have: 4 results","want: one result"}')::dis.score,
            'One Result: OK because has multiple results'
        ),
        dis.same(
            dis.one_result('SELECT * WHERE'),
            ('FAIL', '', '{"call: SELECT * WHERE","have: failed to execute","want: one result"}')::dis.score,
            'One Result: FAIL because of execution failure'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_244_one_result() OWNER TO postgres;

--
-- Name: FUNCTION test_244_one_result(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_244_one_result() IS 'Ensure dis.one_result operates as expected (2012-04-14)';


SET search_path = dis_v1, pg_catalog;

--
-- Name: module_summary_xml(text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION module_summary_xml(schema text, module text, detail boolean DEFAULT false) RETURNS xml
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
-- Name: run_tests_xml(text, text, text); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION run_tests_xml(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS xml
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
-- Name: schema_summary_xml(text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION schema_summary_xml(schema text, detail boolean DEFAULT false) RETURNS xml
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
-- Name: schemata_summary_xml(); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION schemata_summary_xml() RETURNS xml
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
-- Name: submodule_summary_xml(text, text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false) RETURNS xml
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
-- Name: test_report_xml(text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE FUNCTION test_report_xml(test_schema text, test_name text, detail boolean DEFAULT false) RETURNS xml
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
-- Name: assertion_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE VIEW assertion_summary AS
    SELECT result.schema, result.module, result.submodule, result.name AS test, (unnest(result.detail)).status AS status, (unnest(result.detail)).message AS message, (unnest(result.detail)).detail AS detail, result.modified_at, result.modified_by FROM result;


ALTER TABLE dis.assertion_summary OWNER TO postgres;

--
-- Name: VIEW assertion_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW assertion_summary IS 'Summary of results by assertion (2012-04-17)';


--
-- Name: module_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE VIEW module_summary AS
    SELECT result.schema, result.module, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module;


ALTER TABLE dis.module_summary OWNER TO postgres;

--
-- Name: VIEW module_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW module_summary IS 'Summary of test results by schema module (2012-03-16)';


--
-- Name: schema_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE VIEW schema_summary AS
    SELECT result.schema, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema;


ALTER TABLE dis.schema_summary OWNER TO postgres;

--
-- Name: VIEW schema_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW schema_summary IS 'Summary of schema test results (2012-03-16)';


--
-- Name: submodule_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE VIEW submodule_summary AS
    SELECT result.schema, result.module, result.submodule, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module, result.submodule;


ALTER TABLE dis.submodule_summary OWNER TO postgres;

--
-- Name: VIEW submodule_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW submodule_summary IS 'Summary of test results by schema module submodule (2012-03-16)';


--
-- Name: test; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE VIEW test AS
    SELECT pg_proc.proname AS name, pg_namespace.nspname AS schema, COALESCE("substring"(pg_proc.prosrc, '--\\s+module[:]\\s+(\\S+)'::text), ''::text) AS module, COALESCE("substring"(pg_proc.prosrc, '--\\s+submodule[:]\\s+(\\S+)'::text), ''::text) AS submodule, COALESCE(("substring"(pg_proc.prosrc, '--\\s+plan[:]\\s+(\\d+)'::text))::integer, 0) AS plan FROM (pg_namespace LEFT JOIN pg_proc ON ((pg_proc.pronamespace = pg_namespace.oid))) WHERE ((pg_namespace.nspname ~ '_test$'::text) AND (pg_proc.proname ~ '^test_'::text));


ALTER TABLE dis.test OWNER TO postgres;

--
-- Name: VIEW test; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW test IS 'Tests that can be executed (2012-03-15)';


SET search_path = dis_history, pg_catalog;

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


SET search_path = dis, pg_catalog;

--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema);


SET search_path = dis_history, pg_catalog;

--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis_history; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema, modified_at);


SET search_path = dis, pg_catalog;

--
-- Name: t_50_modified; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_50_modified BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE modified();


--
-- Name: t_90_history; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_90_history BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE dis_history.result_saver();


--
-- Name: dis; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis FROM PUBLIC;
REVOKE ALL ON SCHEMA dis FROM postgres;
GRANT ALL ON SCHEMA dis TO postgres;
GRANT ALL ON SCHEMA dis TO PUBLIC;


--
-- Name: dis_example_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_example_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_example_test FROM postgres;
GRANT ALL ON SCHEMA dis_example_test TO postgres;
GRANT ALL ON SCHEMA dis_example_test TO PUBLIC;


--
-- Name: dis_history; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_history FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_history FROM postgres;
GRANT ALL ON SCHEMA dis_history TO postgres;
GRANT ALL ON SCHEMA dis_history TO PUBLIC;


--
-- Name: dis_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_test FROM postgres;
GRANT ALL ON SCHEMA dis_test TO postgres;
GRANT ALL ON SCHEMA dis_test TO PUBLIC;


--
-- Name: dis_v1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_v1 FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_v1 FROM postgres;
GRANT ALL ON SCHEMA dis_v1 TO postgres;
GRANT ALL ON SCHEMA dis_v1 TO PUBLIC;


--
-- Name: run_tests(text, text, text); Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM PUBLIC;
REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO PUBLIC;


--
-- Name: result; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE result TO postgres;
GRANT SELECT,INSERT,DELETE ON TABLE result TO PUBLIC;


--
-- Name: assertion_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE assertion_summary FROM PUBLIC;
REVOKE ALL ON TABLE assertion_summary FROM postgres;
GRANT ALL ON TABLE assertion_summary TO postgres;
GRANT SELECT ON TABLE assertion_summary TO PUBLIC;


--
-- Name: module_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE module_summary FROM PUBLIC;
REVOKE ALL ON TABLE module_summary FROM postgres;
GRANT ALL ON TABLE module_summary TO postgres;
GRANT SELECT ON TABLE module_summary TO PUBLIC;


--
-- Name: schema_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE schema_summary FROM PUBLIC;
REVOKE ALL ON TABLE schema_summary FROM postgres;
GRANT ALL ON TABLE schema_summary TO postgres;
GRANT SELECT ON TABLE schema_summary TO PUBLIC;


--
-- Name: submodule_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE submodule_summary FROM PUBLIC;
REVOKE ALL ON TABLE submodule_summary FROM postgres;
GRANT ALL ON TABLE submodule_summary TO postgres;
GRANT SELECT ON TABLE submodule_summary TO PUBLIC;


--
-- Name: test; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE test FROM PUBLIC;
REVOKE ALL ON TABLE test FROM postgres;
GRANT ALL ON TABLE test TO postgres;
GRANT SELECT ON TABLE test TO PUBLIC;


SET search_path = dis_history, pg_catalog;

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

COMMIT;
