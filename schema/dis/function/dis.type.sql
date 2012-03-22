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
-- Name: type(anyelement, regtype, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION type(have anyelement, want regtype, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.type(have anyelement, want regtype, message text)
    Description:  Check if have is the provided regtype
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  want (regtype): Postgres regtype name to check against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        pg_typeof($1) IS NOT DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have type: ' || COALESCE(pg_typeof($1)::text, 'NULL')),
            ('want type: ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.type(have anyelement, want regtype, message text) OWNER TO postgres;

--
-- Name: FUNCTION type(have anyelement, want regtype, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION type(have anyelement, want regtype, message text) IS 'DR: Check if have is the provided regtype (2012-03-20)';


--
-- PostgreSQL database dump complete
--

