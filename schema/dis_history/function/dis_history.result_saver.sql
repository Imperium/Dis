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

--
-- Name: result_saver(); Type: FUNCTION; Schema: dis_history; Owner: postgres
--

CREATE OR REPLACE FUNCTION result_saver() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
/*  Function:     dis_history.result_saver()
    Description:  Saves each insert in history table
    Affects:      Records each test result in the history table
    Arguments:    none
    Returns:      trigger
*/
DECLARE
BEGIN
    INSERT INTO dis_history.result VALUES ((NEW).*);
    RETURN NEW;
END;
$$;


ALTER FUNCTION dis_history.result_saver() OWNER TO postgres;

--
-- Name: FUNCTION result_saver(); Type: COMMENT; Schema: dis_history; Owner: postgres
--

COMMENT ON FUNCTION result_saver() IS 'Saves each insert in history table (2012-03-16)';


--
-- PostgreSQL database dump complete
--

