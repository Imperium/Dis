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

