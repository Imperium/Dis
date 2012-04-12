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
-- Name: test_220_raises(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_220_raises() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.raises works as expected
-- plan: 6
-- module: assertions
-- submodule: raises
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.raises('SELECT 5 / 0'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on any error'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', '22012'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on SQLSTATE 22012'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', 'division by zero'),
            ('OK', '', '{}')::dis.score,
            'Raises: OK on SQLERRM division by zero'
        ),
        dis.same(
            dis.raises('select 5 >>= 0', 'division by zero'),
            ('FAIL', '', '{"call: select 5 >>= 0","have: 42883/operator does not exist: integer >>= integer (SQLSTATE/SQLERRM)","want: SQLERRM division by zero"}')::dis.score,
            'Raises: FAIL on wrong SQLERRM'
        ),
        dis.same(
            dis.raises('SELECT 5 / 0', '42883'),
            ('FAIL', '', '{"call: SELECT 5 / 0","have: 22012/division by zero (SQLSTATE/SQLERRM)","want: SQLSTATE 42883"}')::dis.score,
            'Raises: FAIL on wrong SQLSTATE'
        ),
        dis.same(
            dis.raises('SELECT 5'),
            ('FAIL', '', '{"call: SELECT 5","have: no error raised","want: Any Error"}')::dis.score,
            'Raises: FAIL on no error raised'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_220_raises() OWNER TO postgres;

--
-- Name: FUNCTION test_220_raises(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_220_raises() IS 'Ensure dis.raises works as expected (2012-04-11)';


--
-- PostgreSQL database dump complete
--

