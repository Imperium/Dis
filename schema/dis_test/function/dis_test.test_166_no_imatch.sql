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
-- Name: test_166_no_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_166_no_imatch() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.no_imatch works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.no_imatch('This is a string', 's is a s'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression, case insensitive, s is a s"}')::dis.score,
            'No Insensive Match: FAIL because substring'
        ),
        dis.same(
            dis.no_imatch('This is A string', 's is a s'),
            ('FAIL', '', '{"have: This is A string","want: do not match the regular expression, case insensitive, s is a s"}')::dis.score,
            'No Insensive Match: FAIL due to case insensitivity'
        ),
        dis.same(
            dis.no_imatch('This is a string', '^This.*string$'),
            ('FAIL', '', '{"have: This is a string","want: do not match the regular expression, case insensitive, ^This.*string$"}')::dis.score,
            'No Insensive Match: FAIL with simple regex'
        ),
        dis.same(
            dis.no_imatch('This is a string', 'want'),
            ('OK', '', '{}')::dis.score,
            'No Insensive Match: OK with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_166_no_imatch() OWNER TO postgres;

--
-- Name: FUNCTION test_166_no_imatch(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_166_no_imatch() IS 'Ensure dis.no_imatch works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

