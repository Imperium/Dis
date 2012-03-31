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
-- Name: test_164_imatch(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_164_imatch() RETURNS void
    LANGUAGE plpgsql
    AS $_$
-- description: Ensure dis.imatch works as expected
-- plan: 4
-- module: assertions
-- submodule: match
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.imatch('This is a string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK'
        ),
        dis.same(
            dis.imatch('This is A string', 's is a s'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK on case insensitivity'
        ),
        dis.same(
            dis.imatch('This is a string', '^This.*string$'),
            ('OK', '', '{}')::dis.score,
            'Insensive Match: OK with simple regex'
        ),
        dis.same(
            dis.imatch('This is a string', 'want'),
            ('FAIL', '', '{"have: This is a string","want: match the regular expression, case insensitive, want"}')::dis.score,
            'Insensive Match: FAIL with missing string'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$_$;


ALTER FUNCTION dis_test.test_164_imatch() OWNER TO postgres;

--
-- Name: FUNCTION test_164_imatch(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_164_imatch() IS 'Ensure dis.imatch works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

