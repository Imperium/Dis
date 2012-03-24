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
-- Name: match(text, text, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION match(have text, regex text, message text DEFAULT ''::text) RETURNS score
    LANGUAGE sql IMMUTABLE
    AS $_$
/*  Function:     dis.match(have text, regex text, message text DEFAULT '')
    Description:  Test if have matches regex
    Affects:      nothing
    Arguments:    have (text): Text that should match the provided regular expression
                  regex (text): Regular expression to test against have
                  message (text): Message to include
    Returns:      dis.score
*/
    SELECT dis.assert(
        $1 ~ $2,
        $3,
        ARRAY[
            ('have: ' || COALESCE($1::text, 'NULL')),
            ('want: match the regular expression ' || COALESCE($2::text, 'NULL'))
        ]
    );
$_$;


ALTER FUNCTION dis.match(have text, regex text, message text) OWNER TO postgres;

--
-- Name: FUNCTION match(have text, regex text, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION match(have text, regex text, message text) IS 'DR: Test if have matches regex (2012-03-23)';


--
-- PostgreSQL database dump complete
--

