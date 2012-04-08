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
-- Name: schemata_summary_xml(); Type: FUNCTION; Schema: dis_v1; Owner: postgres
--

CREATE OR REPLACE FUNCTION schemata_summary_xml() RETURNS xml
    LANGUAGE sql STABLE
    AS $$
/*  Function:     dis_v1.schemata_summary_xml()
    Description:  Summary of all schemata test results
    Affects:      nothing
    Arguments:    none
    Returns:      XML
*/
    SELECT xmlelement(name "Schemata",
        (SELECT xmlagg(
            dis_v1.schema_summary_xml(schema, FALSE)
        ) FROM (SELECT schema FROM dis.schema_summary ORDER BY schema) as s)
    );
$$;


ALTER FUNCTION dis_v1.schemata_summary_xml() OWNER TO postgres;

--
-- Name: FUNCTION schemata_summary_xml(); Type: COMMENT; Schema: dis_v1; Owner: postgres
--

COMMENT ON FUNCTION schemata_summary_xml() IS 'Summary of all schemata test results (2012-04-08)';


--
-- PostgreSQL database dump complete
--

