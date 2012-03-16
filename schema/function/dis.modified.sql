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
-- Name: modified(); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION modified() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.modified()
    Description:  Properly set modified_at modified_by
    Affects:      Active record
    Arguments:    none
    Returns:      trigger
*/
DECLARE
BEGIN
    NEW.modified_at := CURRENT_TIMESTAMP;
    NEW.modified_by := CURRENT_USER;
    RETURN NEW;
END;
$_$;


ALTER FUNCTION dis.modified() OWNER TO postgres;

--
-- Name: FUNCTION modified(); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION modified() IS 'Properly set modified_at modified_by (2012-03-15)';


--
-- PostgreSQL database dump complete
--
