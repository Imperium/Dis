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
-- Name: status_agg(text); Type: AGGREGATE; Schema: dis; Owner: postgres
--

CREATE AGGREGATE status_agg(text) (
    SFUNC = status_test,
    STYPE = text
);


ALTER AGGREGATE dis.status_agg(text) OWNER TO postgres;

--
-- Name: AGGREGATE status_agg(text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON AGGREGATE status_agg(text) IS 'Aggregate test status (2012-03-15)';


--
-- PostgreSQL database dump complete
--

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: result; Type: TABLE; Schema: dis; Owner: postgres; Tablespace: 
--

CREATE TABLE result (
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_by character varying DEFAULT "current_user"() NOT NULL,
    name text NOT NULL,
    schema text NOT NULL,
    module text,
    submodule text,
    plan integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'FAIL'::text NOT NULL,
    tests integer DEFAULT 0 NOT NULL,
    successes integer DEFAULT 0 NOT NULL,
    failures integer DEFAULT 0 NOT NULL,
    summary text NOT NULL,
    detail score[] DEFAULT '{}'::score[] NOT NULL
);


ALTER TABLE dis.result OWNER TO postgres;

--
-- Name: TABLE result; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TABLE result IS 'Results of test runs (2012-03-15)';


--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema);


--
-- Name: t_50_modified; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_50_modified BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE modified();


--
-- Name: t_90_history; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_90_history BEFORE INSERT ON result FOR EACH ROW EXECUTE PROCEDURE dis_history.result_saver();


--
-- Name: result; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE result TO postgres;
GRANT SELECT,INSERT,DELETE ON TABLE result TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_history, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: result; Type: TABLE; Schema: dis_history; Owner: postgres; Tablespace: 
--

CREATE TABLE result (
    modified_at timestamp with time zone NOT NULL,
    modified_by character varying NOT NULL,
    name text NOT NULL,
    schema text NOT NULL,
    module text,
    submodule text,
    plan integer NOT NULL,
    status text NOT NULL,
    tests integer NOT NULL,
    successes integer NOT NULL,
    failures integer NOT NULL,
    summary text NOT NULL,
    detail dis.score[] NOT NULL
);


ALTER TABLE dis_history.result OWNER TO postgres;

--
-- Name: TABLE result; Type: COMMENT; Schema: dis_history; Owner: postgres
--

COMMENT ON TABLE result IS 'Results of all test runs (2012-03-15)';


--
-- Name: result_pkey; Type: CONSTRAINT; Schema: dis_history; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema, modified_at);


--
-- Name: result; Type: ACL; Schema: dis_history; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,REFERENCES,TRIGGER ON TABLE result TO postgres;
GRANT SELECT ON TABLE result TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
    SELECT result.schema, result.module, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module;


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
    SELECT result.schema, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema;


ALTER TABLE dis.schema_summary OWNER TO postgres;

--
-- Name: VIEW schema_summary; Type: COMMENT; Schema: dis; Owner: postgres
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
-- Name: submodule_summary; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW submodule_summary AS
    SELECT result.schema, result.module, result.submodule, count(result.name) AS tests, status_agg(result.status) AS status_agg, sum(result.plan) AS plan, sum(result.tests) AS run, sum(result.successes) AS successes, sum(result.failures) AS failures FROM result GROUP BY result.schema, result.module, result.submodule;


ALTER TABLE dis.submodule_summary OWNER TO postgres;

--
-- Name: VIEW submodule_summary; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW submodule_summary IS 'DR: Summary of test results by schema module submodule (2012-03-16)';


--
-- Name: submodule_summary; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE submodule_summary FROM PUBLIC;
REVOKE ALL ON TABLE submodule_summary FROM postgres;
GRANT ALL ON TABLE submodule_summary TO postgres;
GRANT SELECT ON TABLE submodule_summary TO PUBLIC;


--
-- PostgreSQL database dump complete
--

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
-- Name: test; Type: VIEW; Schema: dis; Owner: postgres
--

CREATE OR REPLACE VIEW test AS
    SELECT pg_proc.proname AS name, pg_namespace.nspname AS schema, COALESCE("substring"(pg_proc.prosrc, '--\\s+module[:]\\s+(\\S+)'::text), ''::text) AS module, COALESCE("substring"(pg_proc.prosrc, '--\\s+submodule[:]\\s+(\\S+)'::text), ''::text) AS submodule, COALESCE(("substring"(pg_proc.prosrc, '--\\s+plan[:]\\s+(\\d+)'::text))::integer, 0) AS plan FROM (pg_namespace LEFT JOIN pg_proc ON ((pg_proc.pronamespace = pg_namespace.oid))) WHERE ((pg_namespace.nspname ~ '_test$'::text) AND (pg_proc.proname ~ '^test_'::text));


ALTER TABLE dis.test OWNER TO postgres;

--
-- Name: VIEW test; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON VIEW test IS 'Tests that can be executed (2012-03-15)';


--
-- Name: test; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE test FROM PUBLIC;
REVOKE ALL ON TABLE test FROM postgres;
GRANT ALL ON TABLE test TO postgres;
GRANT SELECT ON TABLE test TO PUBLIC;


--
-- PostgreSQL database dump complete
--

