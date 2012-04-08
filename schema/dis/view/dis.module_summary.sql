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
-- Name: module_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW module_summary AS
    SELECT result.schema, result.module, count(result.name) AS tests, status_agg(result.status) AS status, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module;


ALTER TABLE dis.module_summary OWNER TO postgres;

--
-- Name: VIEW module_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW module_summary IS 'DR: Summary of test results by schema module (2012-03-16)';


--
-- Name: module_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE module_summary FROM PUBLIC;
REVOKE ALL ON TABLE module_summary FROM postgres;
GRANT ALL ON TABLE module_summary TO postgres;
GRANT SELECT ON TABLE module_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

