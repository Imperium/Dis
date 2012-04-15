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

