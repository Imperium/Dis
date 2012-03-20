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
                  message (text): descrition of the test
                  detail (text[]): array of text with detail on the test performed
    Returns:      text
*/
DECLARE
    _state      text := 'FAIL';
    _message    text := COALESCE(message, '');
    _detail     text := COALESCE(detail, '{}'::text[]);
    _score      dis.score;
BEGIN
    IF assertion IS NOT DISTINCT FROM TRUE THEN
        _state := 'OK';
    END IF;
    _score := (_state, _message, _detail)::dis.score;
    RETURN _score;
END;
$$;


ALTER FUNCTION dis.assert(assertion boolean, message text, detail text[]) OWNER TO postgres;

--
-- Name: FUNCTION assert(assertion boolean, message text, detail text[]); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION assert(assertion boolean, message text, detail text[]) IS 'Validate a test assertion (2012-03-14)';


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
-- Name: skip(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION skip(message text) RETURNS score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.skip(message text DEFAULT 'Skipped Test')
    Description:  Return a test skip score
    Affects:      nothing
    Arguments:    message text DEFAULT 'Skipped Test': Message to include in the dis.score
    Returns:      dis.score
*/
    SELECT ('SKIP', $1, '{}'::text[])::dis.score;
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

CREATE OR REPLACE FUNCTION todo(message text DEFAULT 'Test Placeholder'::text) RETURNS score
    LANGUAGE sql
    AS $_$
/*  Function:     dis.todo(message text DEFAULT 'Test Placeholder')
    Description:  Placdholder for a real test to be added later
    Affects:      nothing
    Arguments:    message text: Message to include
    Returns:      dis.score
*/
    SELECT ('TODO', $1, '{}'::text[])::dis.score;
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
