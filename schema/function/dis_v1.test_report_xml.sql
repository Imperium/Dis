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
-- Name: test_report_xml(test_schema text, test_name text); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_report_xml(test_schema text, test_name text) RETURNS xml
    LANGUAGE sql
    STABLE
    AS $_$
/*  Function:     dis_v1.test_report_xml(test_schema text, test_name text)
    Description:  Return the current results of the specified test as XML
    Affects:      nothing
    Arguments:    test_schema (text): schema of the test
                  test_name (text): name of the test
    Returns:      xml
*/
    SELECT xmlelement(name "Test",
        xmlelement(name "Schema", schema),
        xmlelement(name "Name", name),
        xmlelement(name "Module", module),
        xmlelement(name "SubModule", submodule),
        xmlelement(name "Status", status),
        xmlelement(name "Summary", summary),
        xmlelement(name "Statistics",
            xmlelement(name "Plan", plan),
            xmlelement(name "Run", tests),
            xmlelement(name "Successes", successes),
            xmlelement(name "Failures", failures)
        ),
        xmlelement(name "Assertions",
            (SELECT xmlagg(
                xmlelement(name "Assertion",
                    xmlelement(name "Status", status),
                    xmlelement(name "Message", message)
                )
            ) FROM (SELECT (unnest(detail)).*) AS foo)
        )
    ) FROM dis.result WHERE schema = $1 AND name = $2;
$_$;


ALTER FUNCTION dis_v1.test_report_xml(test_schema text, test_name text) OWNER TO postgres;

--
-- Name: FUNCTION test_report_xml(test_schema text, test_name text); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION test_report_xml(test_schema text, test_name text) IS 'DR: Return the current results of the specified test as XML (2012-03-16)';

--
-- PostgreSQL database dump complete
--
