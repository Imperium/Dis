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
-- Name: dis_example_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_example_test;


ALTER SCHEMA dis_example_test OWNER TO postgres;

--
-- Name: dis_example_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_example_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_example_test FROM postgres;
GRANT ALL ON SCHEMA dis_example_test TO postgres;
GRANT ALL ON SCHEMA dis_example_test TO PUBLIC;


--
-- PostgreSQL database dump complete
--

DROP FUNCTION dis_test.test_alpha();
DROP FUNCTION dis_test.test_beta();
DROP FUNCTION dis_test.test_gamma();
DROP FUNCTION dis_test.test_delta();
DROP FUNCTION dis_test.test_epsilon();

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
-- Name: _count(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION _count(call text) RETURNS integer
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
-- Name: compare(anyelement, text, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION compare(have anyelement, operator text, against anyelement, message text DEFAULT ''::text) RETURNS score
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
-- Name: compare(anyelement, text, mold, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION compare(have anyelement, operator text, against mold, message text DEFAULT ''::text) RETURNS score
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
-- Name: FUNCTION compare(have anyelement, operator text, against anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against anyelement, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


--
-- Name: FUNCTION compare(have anyelement, operator text, against mold, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against mold, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


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
-- Name: has_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION has_result(call text, message text DEFAULT ''::text) RETURNS score
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
-- Name: mold(anyelement); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION mold(value anyelement) RETURNS mold
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
-- Name: one_result(text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION one_result(call text, message text DEFAULT ''::text) RETURNS score
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

CREATE OR REPLACE FUNCTION run_test(schema text, name text) RETURNS boolean
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

CREATE OR REPLACE FUNCTION run_tests(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS boolean
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
-- Name: run_tests(text, text, text); Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM PUBLIC;
REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO PUBLIC;


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

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_alpha(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
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


ALTER FUNCTION dis_example_test.test_alpha() OWNER TO postgres;

--
-- Name: FUNCTION test_alpha(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
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

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_beta(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
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


ALTER FUNCTION dis_example_test.test_beta() OWNER TO postgres;

--
-- Name: FUNCTION test_beta(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
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

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_delta(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
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


ALTER FUNCTION dis_example_test.test_delta() OWNER TO postgres;

--
-- Name: FUNCTION test_delta(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
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

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_epsilon(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
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


ALTER FUNCTION dis_example_test.test_epsilon() OWNER TO postgres;

--
-- Name: FUNCTION test_epsilon(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_epsilon() IS 'Demo test (2012-03-15)';


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

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_gamma(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
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


ALTER FUNCTION dis_example_test.test_gamma() OWNER TO postgres;

--
-- Name: FUNCTION test_gamma(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
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

SET search_path = dis_test, pg_catalog;

--
-- Name: test_070__count(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_070__count() RETURNS void
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
-- Name: test_180_compare(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_180_compare() RETURNS void
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
-- Name: test_185_compare(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_185_compare() RETURNS void
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
-- Name: test_220_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_220_raises() RETURNS void
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
-- Name: test_225_not_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_225_not_raises() RETURNS void
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
-- Name: test_240_no_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_240_no_result() RETURNS void
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
-- Name: test_242_has_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_242_has_result() RETURNS void
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
-- Name: test_244_one_result(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_244_one_result() RETURNS void
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


--
-- PostgreSQL database dump complete
--



COMMIT;
