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
-- Name: module_summary_xml(text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION module_summary_xml(schema text, module text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.module_summary_xml(schema text, module text, detail boolean DEFAULT FALSE)
    Description:  XML summary of the schema/module requested
    Affects:      nothing
    Arguments:    schema (text): schema name
                  module (text): module name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "Module",
        xmlelement(name "Name", s.module),
        xmlelement(name "Schema", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $3 IS TRUE THEN
            xmlelement(name "SubModules",
                (SELECT xmlagg(
                    dis_v1.submodule_summary_xml(a.schema, a.module, a.submodule, FALSE)
                ) FROM (SELECT schema, module, submodule FROM dis.submodule_summary WHERE schema = $1 AND module = $2 ORDER by submodule) AS a)
            )
            ELSE NULL
        END
    ) FROM dis.module_summary AS s WHERE s.schema = $1 AND s.module = $2;
$_$;


ALTER FUNCTION dis_v1.module_summary_xml(schema text, module text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION module_summary_xml(schema text, module text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION module_summary_xml(schema text, module text, detail boolean) IS 'XML summary of the schema/module requested (2012-04-01)';


--
-- PostgreSQL database dump complete
--

