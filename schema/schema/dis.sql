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
-- Name: dis; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis;


ALTER SCHEMA dis OWNER TO postgres;

--
-- Name: dis; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis FROM PUBLIC;
REVOKE ALL ON SCHEMA dis FROM postgres;
GRANT ALL ON SCHEMA dis TO postgres;
GRANT ALL ON SCHEMA dis TO PUBLIC;


--
-- PostgreSQL database dump complete
--

