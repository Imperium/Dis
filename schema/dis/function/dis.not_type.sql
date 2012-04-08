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
-- Name: not_type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION not_type(have anyelement, notwant regtype, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.not_type(have anyelement, notwant regtype, message text)
    Description:  Check if have is not the provided regtype
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  notwant (regtype): Postgres regtype name to check against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        pg_typeof($1) IS DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have type: ' || COALESCE(pg_typeof($1)::text, 'NULL')),
            ('notwant type: ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.not_type(have anyelement, notwant regtype, message text) OWNER TO postgres;

--
-- Name: FUNCTION not_type(have anyelement, notwant regtype, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION not_type(have anyelement, notwant regtype, message text) IS 'Check if have is not the provided regtype (2012-03-20)';


--
-- PostgreSQL database dump complete
--

