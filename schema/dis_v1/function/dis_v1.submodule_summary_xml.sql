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
-- Name: submodule_summary_xml(text, text, text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false)
    Description:  XML summary of the schema/module/submodule requested
    Affects:      nothing
    Arguments:    schema (text): schema name
                  module (text): module name
                  submodule (text): submodule name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "SubModule", 
        xmlelement(name "SubModule", s.submodule),
        xmlelement(name "Module", s.module),
        xmlelement(name "Schema", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $4 IS TRUE THEN
            xmlelement(name "Tests", 
                (SELECT xmlagg(
                    dis_v1.test_report_xml(foo.schema, foo.name, FALSE)
                ) FROM (SELECT schema, name FROM dis.test AS t WHERE t.schema = $1 AND t.module = $2 AND t.submodule = $3 ORDER BY name) AS foo)
            )
            ELSE NULL
        END
    ) FROM dis.submodule_summary AS s WHERE s.schema = $1 AND s.module = $2 AND s.submodule = $3;
$_$;


ALTER FUNCTION dis_v1.submodule_summary_xml(schema text, module text, submodule text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION submodule_summary_xml(schema text, module text, submodule text, detail boolean) IS 'XML summary of the schema/module/submodule requested (2012-04-01)';


--
-- PostgreSQL database dump complete
--

