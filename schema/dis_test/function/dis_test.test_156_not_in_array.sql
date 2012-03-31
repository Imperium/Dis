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
-- Name: test_156_not_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_156_not_in_array() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.not_in_array works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.not_in_array(1, ARRAY[1,4,7]),
            ('FAIL', '', '{"have: 1 (integer)","want: not one of {1,4,7} (integer[])"}')::dis.score,
            'Not In Array: FAIL element in array'
        ),
        dis.same(
            dis.not_in_array(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('FAIL', '', '{"have: {1,4,7} (integer[])","want: each not one of {4,7,1} (integer[])"}')::dis.score,
            'Not In Array: FAIL elements in array'
        ),
        dis.same(
            dis.not_in_array(1, ARRAY[2,4,7]),
            ('OK', '', '{}')::dis.score,
            'Not In Array: OK element missing from array'
        ),
        dis.same(
            dis.not_in_array(ARRAY[1,4,11], ARRAY[1,4,7,10]),
            ('OK', '', '{}')::dis.score,
            'Not In Array: OK not all elements in array'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_156_not_in_array() OWNER TO postgres;

--
-- Name: FUNCTION test_156_not_in_array(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_156_not_in_array() IS 'Ensure dis.not_in_array works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

