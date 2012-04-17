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
-- Name: dis_example_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_example_test;


ALTER SCHEMA dis_example_test OWNER TO postgres;

--
-- Name: dis_example_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_example_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_example_test FROM postgres;
GRANT ALL ON SCHEMA dis_example_test TO postgres;
GRANT ALL ON SCHEMA dis_example_test TO PUBLIC;


--
-- PostgreSQL database dump complete
--

