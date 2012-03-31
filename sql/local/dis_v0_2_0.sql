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
-- Name: dis_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_test;


ALTER SCHEMA dis_test OWNER TO postgres;

--
-- Name: dis_test; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_test FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_test FROM postgres;
GRANT ALL ON SCHEMA dis_test TO postgres;
GRANT ALL ON SCHEMA dis_test TO PUBLIC;


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

--
-- Name: dis_v1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dis_v1;


ALTER SCHEMA dis_v1 OWNER TO postgres;

--
-- Name: dis_v1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA dis_v1 FROM PUBLIC;
REVOKE ALL ON SCHEMA dis_v1 FROM postgres;
GRANT ALL ON SCHEMA dis_v1 TO postgres;
GRANT ALL ON SCHEMA dis_v1 TO PUBLIC;


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
-- Name: score; Type: TYPE; Schema: dis; Owner: postgres
--

CREATE TYPE score AS (
    status text,
    message text,
    detail text[]
);


ALTER TYPE dis.score OWNER TO postgres;

--
-- Name: TYPE score; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TYPE score IS 'Assertion test output (2012-03-19)';


--
-- PostgreSQL database dump complete
--

