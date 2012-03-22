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
-- Name: same(anyelement, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION same(have anyelement, want anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.same(have anyelement, want anyelement, message text DEFAULT '')
    Description:  Test to see if have is not distinct from want
                  *NOTE* "have" and "want" must be of the same type
    Affects:      nothing
    Arguments:    have (anyelement): value to test
                  want (anyelement): value to test against
                  message (text): Descriptive message (optional)
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 IS NOT DISTINCT FROM $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL') || ' (' || pg_typeof($1) || ')'),
            ('want: ' || COALESCE($2::text, 'NULL') || ' (' || pg_typeof($2) || ')')
        ]
    );
$_$;


ALTER FUNCTION dis.same(have anyelement, want anyelement, message text) OWNER TO postgres;

--
-- Name: FUNCTION same(have anyelement, want anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION same(have anyelement, want anyelement, message text) IS 'Test to see if have is not distinct from want (2012-03-19)';


--
-- PostgreSQL database dump complete
--

