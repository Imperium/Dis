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
-- Name: run_tests(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION run_tests(schema text DEFAULT NULL::text, module text DEFAULT NULL::text, submodule text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.run_tests(schema text, module text, submodule text)
    Description:  Run the specified tests
    Affects:      Executes
    Arguments:    schema (text): (Optional) Limit run to tests in this schema
                  module (text): (Optional) Limit run to tests in this module
                  submodule (text): (Optional) Limit run to tests in this submodule
    Returns:      boolean
*/
DECLARE
    _schema     text := schema;
    _module     text := module;
    _submodule  text := submodule;
BEGIN
    IF _schema !~* '_test$' THEN
        _schema := _schema || '_test';
    END IF;
    IF _schema IS NULL THEN
        DELETE FROM dis.result AS r;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSEIF module IS NULL THEN
        DELETE FROM dis.result AS r WHERE r.schema = _schema;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSEIF submodule IS NULL THEN
        DELETE FROM dis.result AS r WHERE r.schema = _schema AND r.module = _module;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema AND test.module = _module
            ORDER BY test.schema, test.module, test.submodule, test.name;
    ELSE
        DELETE FROM dis.result AS r WHERE r.schema = _schema AND r.module = _module AND r.submodule = _submodule;
        PERFORM dis.run_test(test.schema, test.name) FROM dis.test AS test
            WHERE test.schema = _schema AND test.module = _module AND test.submodule = _submodule
            ORDER BY test.schema, test.module, test.submodule, test.name;
    END IF;
    RETURN TRUE;
END;
$_$;


ALTER FUNCTION dis.run_tests(schema text, module text, submodule text) OWNER TO postgres;

--
-- Name: FUNCTION run_tests(schema text, module text, submodule text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION run_tests(schema text, module text, submodule text) IS 'Run the specified tests (2012-03-16)';


--
-- Name: run_tests(text, text, text); Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM PUBLIC;
REVOKE ALL ON FUNCTION run_tests(schema text, module text, submodule text) FROM postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO postgres;
GRANT ALL ON FUNCTION run_tests(schema text, module text, submodule text) TO PUBLIC;


--
-- PostgreSQL database dump complete
--

