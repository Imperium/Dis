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
-- Name: tally(dis.score[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION dis.tally(dis.score[]) RETURNS void
    IMMUTABLE
    LANGUAGE plpgsql
    AS $_$
/*  Function:     dis.tally(dis.score[])
    Description:  Tally scores and throws exception for test reporting
    Affects:      nothing
    Arguments:    dis.score[]: array of dis.score results
    Returns:      void
*/
DECLARE
    v_tallies   ALIAS FOR $1;
    _count      integer         := array_upper(v_tallies, 1);
    _state      text            := 'OK';
    _i          integer;
BEGIN
    IF _count IS NULL THEN
        RAISE EXCEPTION '[FAIL][0]{}';
    END IF;

    FOR _i IN 1.._count LOOP
        IF v_tallies[_i].status NOT IN ('OK', 'TODO', 'SKIP') THEN
            _state := 'FAIL';
            EXIT;
        END IF;
    END LOOP;
    RAISE EXCEPTION '[%][%]%', _state, _count, v_tallies::text;
END;
$_$;


ALTER FUNCTION dis.tally(dis.score[]) OWNER TO postgres;

--
-- Name: FUNCTION tally(dis.score[]); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION tally(dis.score[]) IS 'Tally scores for test reporting (2012-03-14)';


--
-- PostgreSQL database dump complete
--
