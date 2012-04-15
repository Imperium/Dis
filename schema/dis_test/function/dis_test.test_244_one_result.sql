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

