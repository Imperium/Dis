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
-- Name: test_170_type(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_170_type() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.type works as expected
-- plan: 5
-- module: assertions
-- submodule: type
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.type(3, 'integer'),
            ('OK', '', '{}')::dis.score,
            'Type: OK with integer'
        ),
        dis.same(
            dis.type('5'::text, 'integer'),
            ('FAIL', '', '{"have type: text","want type: integer"}')::dis.score,
            'Type: Fail with text vs integer'
        ),
        dis.same(
            dis.type(ARRAY[5], 'integer'),
            ('FAIL', '', '{"have type: integer[]","want type: integer"}')::dis.score,
            'Type: Fail with integer array vs integer'
        ),
        dis.same(
            dis.type('bob'::varchar, 'text'),
            ('FAIL', '', '{"have type: character varying","want type: text"}')::dis.score,
            'Type: Fail with varchar vs text'
        ),
        dis.same(
            dis.type(ARRAY['bob'], 'text'),
            ('FAIL', '', '{"have type: text[]","want type: text"}')::dis.score,
            'Type: Fail with text array vs text'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_170_type() OWNER TO postgres;

--
-- Name: FUNCTION test_170_type(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_170_type() IS 'Ensure dis.type works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

