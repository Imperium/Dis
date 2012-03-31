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
-- Name: test_162_no_match(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_162_no_match() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.no_match works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.no_match('This is a string', 's is a s'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression s is a s"}')::dis.score,
            'No Match: FAIL because substring'
        ),
        dis.same(
            dis.no_match('This is A string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'No Match: OK due to case sensitivity'
        ),
        dis.same(
            dis.no_match('This is a string', '^This.*string$'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression ^This.*string$"}')::dis.score,
            'No Match: FAIL with simple regex'
        ),
        dis.same(
            dis.no_match('This is a string', 'want'),
            ('OK', '', '{}')::dis.score,
            'No Match: OK with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_162_no_match() OWNER TO postgres;

--
-- Name: FUNCTION test_162_no_match(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_162_no_match() IS 'Ensure dis.no_match works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

