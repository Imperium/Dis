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
-- Name: test_160_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_160_match() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.match works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.match('This is a string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Match: OK'
        ),
        dis.same(
            dis.match('This is A string', 's is a s'),
            ('FAIL', '', '{"have: This is A string","want: match the regular expression s is a s"}')::dis.score,
            'Match: FAIL on case sensitivity'
        ),
        dis.same(
            dis.match('This is a string', '^This.*string$'),
            ('OK', '', '{}')::dis.score,
            'Match: OK with simple regex'
        ),
        dis.same(
            dis.match('This is a string', 'want'),
            ('FAIL', '', '{"have: This is a string","want: match the regular expression want"}')::dis.score,
            'Match: FAIL with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_160_match() OWNER TO postgres;

--
-- Name: FUNCTION test_160_match(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_160_match() IS 'Ensure dis.match works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

