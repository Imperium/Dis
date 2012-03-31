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
-- Name: test_154_in_array(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_154_in_array() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.in_array works as expected
-- plan: 4
-- module: assertions
-- submodule: array
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.in_array(1, ARRAY[1,4,7]),
            ('OK', '', '{}')::dis.score,
            'In Array: OK element in array'
        ),
        dis.same(
            dis.in_array(ARRAY[1,4,7], ARRAY[4,7,1]),
            ('OK', '', '{}')::dis.score,
            'In Array: OK elements in array'
        ),
        dis.same(
            dis.in_array(1, ARRAY[2,4,7]),
            ('FAIL', '', '{"have: 1 (integer)","want: one of {2,4,7} (integer[])"}')::dis.score,
            'In Array: FAIL element missing from array'
        ),
        dis.same(
            dis.in_array(ARRAY[1,4,11], ARRAY[1,4,7,10]),
            ('FAIL', '', '{"have: {1,4,11} (integer[])","want: each one of {1,4,7,10} (integer[])"}')::dis.score,
            'In Array: FAIL not all elements in array'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_154_in_array() OWNER TO postgres;

--
-- Name: FUNCTION test_154_in_array(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_154_in_array() IS 'Ensure dis.in_array works as expected (2012-03-30)';


--
-- PostgreSQL database dump complete
--

