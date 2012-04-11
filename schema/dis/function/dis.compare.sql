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
-- Name: compare(anyelement, text, anyelement, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION compare(have anyelement, operator text, against anyelement, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.compare(have anyelement, operator text, against anyelement, message text DEFAULT '')
    Description:  Test "have" vs "against" using "operator"
                  *NOTE* have and against must be of the same type
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  operator (text): Comparison operator
                  against (anyelement): Value to compare against
                  message (text): Descriptive message (Optional)
    Returns:      dis.score
*/
DECLARE
    _returns        boolean;
    _score          dis.score;
BEGIN
    EXECUTE 'SELECT ' || COALESCE(quote_literal( have ), 'NULL') || '::' || pg_typeof(have) || ' '
                      || operator || ' '
                      || COALESCE(quote_literal( against ), 'NULL') || '::' || pg_typeof(against)
        INTO _returns;
    _score := dis.assert(
        _returns,
        message,
        ARRAY[
            ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
            ('operator: ' || operator),
            ('against: ' || COALESCE(against::text, 'NULL') || ' (' || pg_typeof(against) || ')')
        ]
    );
    RETURN _score;
EXCEPTION
    WHEN OTHERS THEN
      _score := dis.assert(
          _returns,
          message,
          ARRAY[
              ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
              ('operator: ' || operator),
              ('against: ' || COALESCE(against::text, 'NULL') || ' (' || pg_typeof(against) || ')'),
              ('error: ' || SQLSTATE || ' -- ' || SQLERRM)
          ]
      );
      RETURN _score;
END;
$$;


ALTER FUNCTION dis.compare(have anyelement, operator text, against anyelement, message text) OWNER TO postgres;

--
-- Name: compare(anyelement, text, mold, text); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION compare(have anyelement, operator text, against mold, message text DEFAULT ''::text) RETURNS score
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.compare_mold(have anyelement, operator text, against mold, message text DEFAULT '')
    Description:  Test "have" vs "against" using "operator"
    Affects:      nothing
    Arguments:    have (anyelement): Value to test
                  operator (text): Comparison operator
                  against (dis.mold): Molded value to compare against
                  message (text): Descriptive message (Optional)
    Returns:      score
*/
DECLARE
    _returns        boolean;
    _score          dis.score;
BEGIN
    EXECUTE 'SELECT ' || COALESCE(quote_literal( have ), 'NULL') || '::' || pg_typeof(have) || ' '
                      || operator || ' '
                      || COALESCE(quote_literal( against.value ), 'NULL') || '::' || against.type
        INTO _returns;
    _score := dis.assert(
        _returns,
        message,
        ARRAY[
            ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
            ('operator: ' || operator),
            ('against: ' || COALESCE(against.value, 'NULL') || ' (' || against.type || ')')
        ]
    );
    RETURN _score;
EXCEPTION
    WHEN OTHERS THEN
      _score := dis.assert(
          _returns,
          message,
          ARRAY[
              ('have: ' || COALESCE(have::text, 'NULL') || ' (' || pg_typeof(have) || ')'),
              ('operator: ' || operator),
              ('against: ' || COALESCE(against.value, 'NULL') || ' (' || against.type || ')'),
              ('error: ' || SQLSTATE || ' -- ' || SQLERRM)
          ]
      );
      RETURN _score;
END;
$$;


ALTER FUNCTION dis.compare(have anyelement, operator text, against mold, message text) OWNER TO postgres;

--
-- Name: FUNCTION compare(have anyelement, operator text, against anyelement, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against anyelement, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


--
-- Name: FUNCTION compare(have anyelement, operator text, against mold, message text); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION compare(have anyelement, operator text, against mold, message text) IS 'Test "have" vs "against" using "operator" (2012-04-10)';


--
-- PostgreSQL database dump complete
--

