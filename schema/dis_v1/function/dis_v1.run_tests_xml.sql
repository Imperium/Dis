--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_v1, pg_catalog;

--
-- Name: run_tests_xml(text, text, text); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_tests_xml(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS xml
    LANGUAGE sql
    AS $_$
/*  Function:     dis_v1.run_tests_xml(schema text DEFAULT NULL, module text DEFAULT NULL, submodule text DEFAULT NULL)
    Description:  Run the specified tests
    Affects:      Executes the tests in the specified schema/module/submodule
    Arguments:    schema (text): (Optional) Limit to this schema
                  module (text): (Optional) Limit to this module
                  submodule (text): (Optional) Limit to this submodule
    Returns:      xml
*/
    SELECT xmlelement(name "Successful", dis.run_tests($1, $2, $3));
$_$;


ALTER FUNCTION dis_v1.run_tests_xml(schema text, module text, submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests_xml(schema text, module text, submodule text); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION run_tests_xml(schema text, module text, submodule text) IS 'DR: Run the specified tests (2012-04-08)';


--
-- PostgreSQL database dump complete
--

