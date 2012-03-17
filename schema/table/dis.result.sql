
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
-- Name: result; Type: TABLE; Schema: dis; Owner: postgres
--

CREATE TABLE result (
    modified_at     timestamp with time zone DEFAULT now() NOT NULL,
    modified_by     character varying DEFAULT CURRENT_USER NOT NULL,
    name            text        NOT NULL,
    schema          text        NOT NULL,
    module          text,
    submodule       text,
    plan            integer     NOT NULL DEFAULT 0,
    status          text        NOT NULL DEFAULT 'FAIL',
    tests           integer     NOT NULL DEFAULT 0,
    successes       integer     NOT NULL DEFAULT 0,
    failures        integer     NOT NULL DEFAULT 0,
    summary         text        NOT NULL,
    detail          dis.score[] NOT NULL DEFAULT '{}'::dis.score[]
);

ALTER TABLE dis.result OWNER TO postgres;

--
-- Name: FUNCTION result; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TABLE result IS 'Results of test runs (2012-03-15)';

--
-- Name: active_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY result
    ADD CONSTRAINT result_pkey PRIMARY KEY (name, schema);

--
-- Name: t_50_modified; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_50_modified
    BEFORE INSERT ON result
    FOR EACH ROW
    EXECUTE PROCEDURE dis.modified();


--
-- Name: t_90_history; Type: TRIGGER; Schema: dis; Owner: postgres
--

CREATE TRIGGER t_90_history
    BEFORE INSERT ON result
    FOR EACH ROW
    EXECUTE PROCEDURE dis_history.result_saver();

--
-- Name: result; Type: ACL; Schema: dis; Owner: postgres
--

REVOKE ALL ON TABLE result FROM PUBLIC;
REVOKE ALL ON TABLE result FROM postgres;
GRANT SELECT,INSERT,DELETE,TRUNCATE,REFERENCES,TRIGGER ON TABLE result TO postgres;
GRANT SELECT,INSERT,DELETE ON TABLE result TO PUBLIC;


--
-- PostgreSQL database dump complete
--
