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

