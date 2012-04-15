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
-- Name: test_185_compare(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_185_compare() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.compare (mold version) works as expected
-- plan: 4
-- module: assertions
-- submodule: compare
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.compare(5, '>', dis.mold(4.0)),
            ('OK', '', '{}')::dis.score,
            'Compare: OK 5 > 4'
        ),
        dis.same(
            dis.compare(5, '<', dis.mold(4.5)),
            ('FAIL', '', '{"have: 5 (integer)","operator: <","against: 4.5 (numeric)"}')::dis.score,
            'Compare: FAIL 5 < 4.5'
        ),
        dis.same(
            dis.compare('10.0.0.0/8'::cidr,'>>=',dis.mold('10.0.0.1/32'::inet)),
            ('OK', '', '{}')::dis.score,
            'Compare: OK  10.0.0.0/8::cidr >>= 10.0.0.1/32::inet'
        ),
        dis.same(
            dis.compare(5, '>>=', dis.mold(4)),
            ('FAIL', '', '{"have: 5 (integer)","operator: >>=","against: 4 (integer)","error: 42883 -- operator does not exist: integer >>= integer"}')::dis.score,
            'Compare: FAIL on unknown operator'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_185_compare() OWNER TO postgres;

--
-- Name: FUNCTION test_185_compare(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_185_compare() IS 'Ensure dis.compare (mold version) works as expected (2012-04-10)';


--
-- PostgreSQL database dump complete
--

