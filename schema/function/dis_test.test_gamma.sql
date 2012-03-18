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
-- Name: test_gamma(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_gamma() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example
-- submodule: basic2
-- plan: 3
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This is a test'),
        dis.assert(TRUE, 'This also works')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_gamma() OWNER TO postgres;

--
-- Name: FUNCTION test_gamma(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_gamma() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

