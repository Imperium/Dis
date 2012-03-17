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
-- Name: run_tests(test_schema text, test_module text, test_submodule text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_tests(test_schema text DEFAULT NULL, test_module text DEFAULT NULL, test_submodule text DEFAULT NULL) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.run_tests(test_schema text, test_module text, test_submodule text)
    Description:  Run the specified tests
    Affects:      Executes
    Arguments:    test_schema (text): (Optional) Limit run to tests in this schema
                  test_module (text): (Optional) Limit run to tests in this module
                  test_submodule (text): (Optional) Limit run to tests in this submodule
    Returns:      boolean
*/
DECLARE
BEGIN
    IF test_schema IS NULL THEN
        DELETE FROM dis.test;
        PERFORM dis.run_test(schema, name) FROM dis.test
            ORDER BY schema, module, submodule, name;
    ELSEIF test_module IS NULL THEN
        DELETE FROM dis.test WHERE schema = test_schema;
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema
            ORDER BY schema, module, submodule, name;
    ELSEIF test_submodule IS NULL THEN
        DELETE FROM dis.test WHERE schema = test_schema AND module = test_module
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema AND module = test_module
            ORDER BY schema, module, submodule, name;
    ELSE
        DELETE FROM dis.test WHERE schema = test_schema AND module = test_module AND submodule = test_submodule
        PERFORM dis.run_test(schema, name) FROM dis.test
            WHERE schema = test_schema AND module = test_module AND submodule = test_submodule
            ORDER BY schema, module, submodule, name;
    END IF;
    RETURN TRUE;
END;
$_$;


ALTER FUNCTION dis.run_tests(test_schema text, test_module text, test_submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests(test_schema text, test_module text, test_submodule text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_tests(test_schema text, test_module text, test_submodule text) IS 'Run the specified tests (2012-03-16)';


--
-- PostgreSQL database dump complete
--
