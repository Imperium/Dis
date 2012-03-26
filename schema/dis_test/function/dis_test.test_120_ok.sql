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
-- Name: test_120_ok(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_120_ok() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.ok functions as expected
-- plan: 3
-- module: assertions
-- submodule: simple
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.ok('OK #1'),
            ('OK', 'OK #1', '{}'::text[])::dis.score,
            'OK test with message'
        ),
        dis.same(
            dis.ok(),
            ('OK', '', '{}'::text[])::dis.score,
            'OK test with no message parameter'
        ),
        dis.assert(
            dis.ok(NULL::text) = ('OK', '', '{}'::text[])::dis.score,
            'OK test with NULL message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_120_ok() OWNER TO postgres;

--
-- Name: FUNCTION test_120_ok(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_120_ok() IS 'Ensure dis.ok functions as expected (2012-03-25)';


--
-- PostgreSQL database dump complete
--

