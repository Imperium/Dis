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
-- Name: test_135_not_same(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_135_not_same() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_same works as expected
-- plan: 2
-- module: assertions
-- submodule: same
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_same(0, 1),
            ('OK', '', '{}')::dis.score,
            'Not Same: OK numeric comparison'
        ),
        dis.same(
            dis.not_same(1, 1),
            ('FAIL', '', '{"have: 1 (integer)","notwant: 1 (integer)"}')::dis.score,
            'Not Same: FAIL numeric comparison'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_135_not_same() OWNER TO postgres;

--
-- Name: FUNCTION test_135_not_same(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_135_not_same() IS 'Ensure dis.not_same works as expected (DATE)';


--
-- PostgreSQL database dump complete
--

