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

DROP FUNCTION dis_test.test_alpha();
DROP FUNCTION dis_test.test_beta();
DROP FUNCTION dis_test.test_gamma();
DROP FUNCTION dis_test.test_delta();
DROP FUNCTION dis_test.test_epsilon();

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
-- Name: mold; Type: TYPE; Schema: dis; Owner: postgres
--

CREATE TYPE mold AS (
    value text,
    type regtype
);


ALTER TYPE dis.mold OWNER TO postgres;

--
-- Name: TYPE mold; Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON TYPE mold IS 'Encapsulation of a value cast to text and the original regtype (2012-04-10)';


--
-- PostgreSQL database dump complete
--

