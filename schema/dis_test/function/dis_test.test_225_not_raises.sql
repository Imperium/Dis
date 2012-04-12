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
-- Name: test_225_not_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_225_not_raises() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_raises works as expected
-- plan: 6
-- module: assertions
-- submodule: raises
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_raises('SELECT 5'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on no error'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', '42883'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on different SQLSTATE'
        ),
        dis.same(
            dis.not_raises('select 5 >>= 0', 'division by zero'),
            ('OK', '', '{}')::dis.score,
            'Not Raises: OK on different SQLERRM'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', 'division by zero'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: division by zero (SQLERRM)"}')::dis.score,
            'Not Raises: FAIL on matching SQLERRM'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0', '22012'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: 22012 (SQLSTATE)"}')::dis.score,
            'Not Raises: FAIL on wrong SQLSTATE'
        ),
        dis.same(
            dis.not_raises('SELECT 5 / 0'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","notwant: Any Error"}')::dis.score,
            'Not Raises: FAIL on no error raised'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_225_not_raises() OWNER TO postgres;

--
-- Name: FUNCTION test_225_not_raises(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_225_not_raises() IS 'Ensure dis.not_raises works as expected (2012-04-11)';


--
-- PostgreSQL database dump complete
--

