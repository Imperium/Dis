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
-- Name: _count(text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION _count(call text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/*  Function:     dis._count(call text)
    Description:  Report the number of rows returned by the provided query
    Affects:      nothing, unless the query does something
    Arguments:    call (text): query to execute
    Returns:      integer: count of results (null if error)
*/
DECLARE
    _count      integer;
BEGIN
    EXECUTE 'SELECT count(*) FROM (' || call || ') AS foo' INTO _count;
    RETURN _count;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$;


ALTER FUNCTION dis._count(call text) OWNER TO postgres;

--
-- Name: FUNCTION _count(call text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION _count(call text) IS 'Report the number of rows returned by the provided query (2012-04-14)';


--
-- PostgreSQL database dump complete
--

