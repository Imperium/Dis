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
-- Name: mold(anyelement); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION mold(value anyelement) RETURNS mold
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.mold(value anyelement)
    Description:  Convert value to a dis.mold
    Affects:      nothing
    Arguments:    value (anyelement): value to cast into a dis.mold
    Returns:      dis.mold
*/
DECLARE
    _mold       dis.mold;
    _distinct   boolean;
BEGIN
    _mold := (
        value::text,
        pg_typeof(value)
    )::dis.mold;

    BEGIN
        EXECUTE 'SELECT ' || COALESCE(quote_literal( value ), 'NULL') || '::' || pg_typeof(value)
                          || ' IS DISTINCT FROM '
                          || COALESCE(quote_literal( _mold.value ), 'NULL') || '::' || _mold.type
            INTO _distinct;
    EXCEPTION
        WHEN OTHERS THEN RAISE EXCEPTION 'Unable to properly mold value "%::%"', _mold.value, _mold.type;
    END;

    IF _distinct IS FALSE THEN
        RETURN _mold;
    END IF;
    RAISE EXCEPTION 'Unable to properly mold value "%::%"', _mold.value, _mold.type;
END;
$$;


ALTER FUNCTION dis.mold(value anyelement) OWNER TO postgres;

--
-- Name: FUNCTION mold(value anyelement); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION mold(value anyelement) IS 'Convert value to a dis.mold (2012-04-10)';


--
-- PostgreSQL database dump complete
--

