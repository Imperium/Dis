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
-- Name: schema_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW schema_summary AS
    SELECT schema, count(name) AS tests, dis.status_agg(status), SUM(plan) AS plan, SUM(tests) AS run, SUM(successes) AS successes, SUM(failures) AS failures FROM dis.result GROUP BY schema;


ALTER TABLE dis.schema_summary OWNER TO postgres;

--
-- Name: TABLE schema_summary; Type: COMMENT; Schema: cod; Owner: postgres
--

COMMENT ON VIEW schema_summary IS 'DR: Summary of schema test results (2012-03-16)';


--
-- Name: schema_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE schema_summary FROM PUBLIC;
REVOKE ALL ON TABLE schema_summary FROM postgres;
GRANT ALL ON TABLE schema_summary TO postgres;
GRANT SELECT ON TABLE schema_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--
