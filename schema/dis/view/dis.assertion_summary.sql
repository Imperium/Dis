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
-- Name: assertion_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW assertion_summary AS
    SELECT result.schema, result.module, result.submodule, result.name AS test, (unnest(result.detail)).status AS status, (unnest(result.detail)).message AS message, (unnest(result.detail)).detail AS detail, result.modified_at, result.modified_by FROM result;


ALTER TABLE dis.assertion_summary OWNER TO postgres;

--
-- Name: VIEW assertion_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW assertion_summary IS 'Summary of results by assertion (2012-04-17)';


--
-- Name: assertion_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE assertion_summary FROM PUBLIC;
REVOKE ALL ON TABLE assertion_summary FROM postgres;
GRANT ALL ON TABLE assertion_summary TO postgres;
GRANT SELECT ON TABLE assertion_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

