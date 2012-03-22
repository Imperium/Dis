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
-- Name: less_equal(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION less_equal(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.less_equal(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test if have is less than or equal to want
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value that have should be less than or equal to
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 <= $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: value less than or equal to ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.less_equal(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION less_equal(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION less_equal(have anyelement, want anyelement, message text) IS 'DR: Test if have is less than or equal to want (2012-03-21)';


--
-- PostgreSQL database dump complete
--

