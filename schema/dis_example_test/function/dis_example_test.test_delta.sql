--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_example_test, pg_catalog;

--
-- Name: test_delta(); Type: FUNCTION; Schema: dis_example_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_delta() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example2
-- submodule: larger
-- plan: 2
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_example_test.test_delta() OWNER TO postgres;

--
-- Name: FUNCTION test_delta(); Type: COMMENT; Schema: dis_example_test; Owner: postgres
--

COMMENT ON FUNCTION test_delta() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

