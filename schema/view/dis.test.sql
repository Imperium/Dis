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
    SELECT pg_proc.proname AS name, 
           pg_namespace.nspname as schema,
           substring(pg_proc.prosrc from E'--\\s+module[:]\\s+(\\S+)') AS module,
           substring(pg_proc.prosrc from E'--\\s+submodule[:]\\s+(\\S+)') AS submodule,
           substring(pg_proc.prosrc from E'--\\s+plan[:]\\s+(\\S+)') AS plan
    FROM pg_namespace LEFT JOIN pg_proc ON pg_proc.pronamespace::oid = pg_namespace.oid::oid
    WHERE pg_namespace.nspname ~ '_test$' AND pg_proc.proname ~ '^test_';


ALTER TABLE dis.test OWNER TO postgres;

--
-- Name: TABLE test; Type: COMMENT; Schema: cod; Owner: postgres
--

COMMENT ON TABLE test IS 'Tests that can be executed (2012-03-15)';


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
