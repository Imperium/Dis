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
-- Name: test_144_less(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_144_less() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.less works as expected
-- plan: 5
-- module: assertions
-- submodule: relative
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.less(3,2),
            ('FAIL', '', '{"have: 3 (integer)","want: value less than 2 (integer)"}')::dis.score,
            'Less: FAIL numeric comparison where greater'
        ),
        dis.same(
            dis.less(2,2),
            ('FAIL', '', '{"have: 2 (integer)","want: value less than 2 (integer)"}')::dis.score,
            'Less: Fail numeric comparison where equal'
        ),
        dis.same(
            dis.less(1,2),
            ('OK', '', '{}')::dis.score,
            'Less: OK numeric comparison where less'
        ),
        dis.same(
            dis.less('23'::text, '3'),
            ('OK', '', '{}')::dis.score,
            'Less: OK text comparison where less'
        ),
        dis.same(
            dis.less('3'::text, '23'),
            ('FAIL', '', '{"have: 3 (text)","want: value less than 23 (text)"}')::dis.score,
            'Less: FAIL text comparison where greater'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_144_less() OWNER TO postgres;

--
-- Name: FUNCTION test_144_less(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_144_less() IS 'Ensure dis.greater works as expected (2012-03-28)';


--
-- PostgreSQL database dump complete
--

