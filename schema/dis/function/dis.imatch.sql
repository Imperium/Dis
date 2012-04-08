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
-- Name: imatch(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION imatch(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.imatch(have text, regex text, message text DEFAULT '')
    Description:  Test if have matches regex, case insensitive
    Affects:      nothing
    Arguments:    have (text): Text that should match the provided regular expression, case insensitive
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 ~* $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: match the regular expression, case insensitive, ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.imatch(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION imatch(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION imatch(have text, regex text, message text) IS 'Test if have matches regex, case insensitive (2012-03-23)';


--
-- PostgreSQL database dump complete
--

