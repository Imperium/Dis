--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = dis_test, pg_catalog;

--
-- Name: test_070__count(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_070__count() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis._count operates as expected
-- plan: 3
-- module: helpers
-- submodule: execute
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis._count('SELECT 5'),
            1,
            '_count: One result'
        ),
        dis.same(
            dis._count('SELECT * FROM dis.test limit 0'),
            0,
            '_count: no result'
        ),
        dis.same(
            dis._count('SELECT * WHERE'),
            null::integer,
            '_count: execution failure'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_070__count() OWNER TO postgres;

--
-- Name: FUNCTION test_070__count(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_070__count() IS 'Ensure dis._count operates as expected (2012-04-14)';


--
-- PostgreSQL database dump complete
--

