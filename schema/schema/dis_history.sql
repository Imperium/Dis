--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: dis_history; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_history;


ALTER SCHEMA dis_history OWNER TO postgres;

--
-- Name: dis_history; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_history FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_history FROM postgres;
GRANT ALL ON SCHEMA dis_history TO postgres;
GRANT ALL ON SCHEMA dis_history TO PUBLIC;


--
-- PostgreSQL database dump complete
--

