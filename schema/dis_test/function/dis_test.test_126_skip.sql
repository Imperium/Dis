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
-- Name: test_126_skip(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_126_skip() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.skip works as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.skip('Skip #1'),
            ('SKIP', 'Skip #1', '{}')::dis.score,
            'Skip assertion with message'
        ),
        dis.same(
            dis.skip(),
            ('SKIP', '', '{}')::dis.score,
            'Skip assertion with no message parameter'
        ),
        dis.same(
            dis.skip(NULL),
            ('SKIP', '', '{}')::dis.score,
            'Skip assertion with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_126_skip() OWNER TO postgres;

--
-- Name: FUNCTION test_126_skip(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_126_skip() IS 'Ensure dis.skip works as expected (DATE)';


--
-- PostgreSQL database dump complete
--

