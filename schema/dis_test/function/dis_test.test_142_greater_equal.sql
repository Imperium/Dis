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
-- Name: test_142_greater_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_142_greater_equal() RETURNS void
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
-- PostgreSQL database dump complete
--

