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
-- Name: run_test(test_schema text, test_name text); Type: FUNCTION; Schema: dis; Owner: postgres
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
                ELSEIF _plan <> _count THEN
                    _status := 'FAIL';
                    _summary := 'Test plan of ' || _plan::text || ' assertions not followed, ' || _count::text || ' assertions reported';
                ELSE
                    _summary := 'Success: ' || _success::text || ' of ' || _count::text || ' assertions passed';
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
