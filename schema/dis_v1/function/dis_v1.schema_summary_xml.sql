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
-- Name: schema_summary_xml(text, boolean); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION schema_summary_xml(schema text, detail boolean DEFAULT false) RETURNS xml
    LANGUAGE sql STABLE
    AS $_$
/*  Function:     dis_v1.schema_summary_xml(schema text, detail boolean DEFAULT FALSE)
    Description:  XML summary of schema results
    Affects:      nothing
    Arguments:    schema (text): schema name
                  detail (boolean): (Optional) If true submodule's tests are included
    Returns:      xml
*/
    SELECT xmlelement(name "Schema",
        xmlelement(name "Name", s.schema),
        xmlelement(name "Status", s.status),
        xmlelement(name "Statistics",
            xmlelement(name "Tests", s.tests),
            xmlelement(name "Plan", s.plan),
            xmlelement(name "Run", s.run),
            xmlelement(name "Successes", s.successes),
            xmlelement(name "Failures", s.failures)
        ),
        CASE WHEN $2 IS TRUE THEN
            xmlelement(name "Module", 
                (SELECT xmlagg(
                    dis_v1.module_summary_xml(foo.schema, foo.module, FALSE)
                ) FROM (SELECT schema, module FROM dis.module_summary AS t WHERE t.schema = $1 ORDER BY module) AS foo)
            )
            ELSE NULL
        END
    ) FROM dis.schema_summary AS s WHERE schema = $1;
$_$;


ALTER FUNCTION dis_v1.schema_summary_xml(schema text, detail boolean) OWNER TO postgres;

--
-- Name: FUNCTION schema_summary_xml(schema text, detail boolean); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION schema_summary_xml(schema text, detail boolean) IS 'XML summary of schema results (2012-04-01)';


--
-- PostgreSQL database dump complete
--

