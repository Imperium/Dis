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
-- Name: test_122_fail(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_122_fail() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.fail functions as expected
-- plan: 3
-- module: assertions
-- submodule: simple
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.fail('Fail #1'),
            ('FAIL', 'Fail #1', '{}')::dis.score,
            'Fail test with message'
        ),
        dis.same(
            dis.fail(),
            ('FAIL', '', '{}')::dis.score,
            'Fail with no message parameter'
        ),
        dis.same(
            dis.fail(NULL),
            ('FAIL', '', '{}')::dis.score,
            'Fail with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_122_fail() OWNER TO postgres;

--
-- Name: FUNCTION test_122_fail(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_122_fail() IS 'Ensure dis.fail functions as expected (DATE)';


--
-- PostgreSQL database dump complete
--

