--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis, pg_catalog;

--
-- Name: test_wrapper(schema text, name text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_wrapper(schema text, name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.test_wrapper(schema text, name text)
    Description:  Test wrapper to ensure an exception is thrown
    Affects:      Executes provided function
    Arguments:    schema (text): schema of the function
                  name (text): name of the function
    Returns:      void
*/
DECLARE
BEGIN
    EXECUTE 'SELECT ' || quote_ident(schema) || '.' || quote_ident(name) || '()';
    RAISE EXCEPTION '[NONE][0][0][0]{}';
END;
$_$;


ALTER FUNCTION dis.test_wrapper(schema text, name text) OWNER TO postgres;

--
-- Name: FUNCTION test_wrapper(schema text, name text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION test_wrapper(schema text, name text) IS 'DR: Test wrapper to ensure an exception is thrown (2012-03-15)';


--
-- PostgreSQL database dump complete
--
