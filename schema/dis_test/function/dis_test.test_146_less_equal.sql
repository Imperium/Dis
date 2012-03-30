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
-- Name: test_146_less_equal(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_146_less_equal() RETURNS void
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
-- PostgreSQL database dump complete
--

