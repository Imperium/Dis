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
-- Name: test_175_not_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_175_not_type() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_type works as expected
-- plan: 5
-- module: assertions
-- submodule: type
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_type(3, 'integer'),
            ('FAIL', '', '{"have type: integer","notwant type: integer"}')::dis.score,
            'Not Type: Fail with integer vs integer'
        ),
        dis.same(
            dis.not_type('5'::text, 'integer'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with text vs integer'
        ),
        dis.same(
            dis.not_type(ARRAY[5], 'integer'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with integer array vs integer'
        ),
        dis.same(
            dis.not_type('bob'::varchar, 'text'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with varchar vs text'
        ),
        dis.same(
            dis.not_type(ARRAY['bob'], 'text'),
            ('OK', '', '{}')::dis.score,
            'Not Type: OK with text array vs text'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_175_not_type() OWNER TO postgres;

--
-- Name: FUNCTION test_175_not_type(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_175_not_type() IS 'Ensure dis.type works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

