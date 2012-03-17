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
-- Name: tally(score[]); Type: FUNCTION; Schema: dis; Owner: postgres
--

CREATE OR REPLACE FUNCTION tally(tallies score[]) RETURNS void
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*  Function:     dis.tally(tallies dis.score[])
    Description:  Tally scores and throws exception for test reporting
    Affects:      nothing
    Arguments:    tallies (dis.score[]): array of dis.score results
    Returns:      void
*/
DECLARE
    _count      integer         := array_upper(tallies, 1);
    _state      text            := 'OK';
    _success    integer         := 0;
    _failure    integer         := 0;
    _i          integer;
BEGIN
    IF _count IS NULL THEN
        RAISE EXCEPTION '[FAIL][0][0][0]{}';
    END IF;

    FOR _i IN 1.._count LOOP
        IF tallies[_i].status IN ('OK', 'TODO', 'SKIP') THEN
            _success := _success + 1;
        ELSE
            _failure := _failure +1;
            _state   := 'FAIL';
        END IF;
    END LOOP;
    RAISE EXCEPTION '[%][%][%][%]%', _state, _count, _success, _failure, tallies::text;
END;
$$;


ALTER FUNCTION dis.tally(tallies score[]) OWNER TO postgres;

--
-- Name: FUNCTION tally(tallies score[]); Type: COMMENT; Schema: dis; Owner: postgres
--

COMMENT ON FUNCTION tally(tallies score[]) IS 'Tally scores for test reporting (2012-03-14)';


--
-- PostgreSQL database dump complete
--

