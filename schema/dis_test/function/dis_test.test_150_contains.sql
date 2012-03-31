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

