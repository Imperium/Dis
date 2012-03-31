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

