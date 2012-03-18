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
-- Name: test_epsilon(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_epsilon() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- module: example2
-- submodule: simple
-- plan: 1
DECLARE
    _scores   dis.score[] := '{}'::dis.score[];
BEGIN
    _scores := ARRAY[
        dis.assert(TRUE, 'This is a test')
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_epsilon() OWNER TO postgres;

--
-- Name: FUNCTION test_epsilon(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_epsilon() IS 'Demo test (2012-03-15)';


--
-- PostgreSQL database dump complete
--

