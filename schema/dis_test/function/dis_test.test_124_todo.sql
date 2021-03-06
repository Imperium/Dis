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
-- Name: test_124_todo(); Type: FUNCTION; Schema: dis_test; Owner: postgres
--

CREATE OR REPLACE FUNCTION test_124_todo() RETURNS void
    LANGUAGE plpgsql
    AS $$
-- description: Ensure dis.todo functions as expected
-- plan: 3
-- module: assertions
-- submodule: faux
DECLARE
    _scores     dis.score[];
BEGIN
    _scores := ARRAY[
        dis.same(
            dis.todo('Todo #1'),
            ('TODO', 'Todo #1', '{}')::dis.score,
            'Todo test with message'
        ),
        dis.same(
            dis.todo(),
            ('TODO', '', '{}')::dis.score,
            'Todo test with no message parameter'
        ),
        dis.same(
            dis.todo(NULL),
            ('TODO', '', '{}')::dis.score,
            'Todo test with null message parameter'
        )
    ];
    PERFORM dis.tally(_scores);
END;
$$;


ALTER FUNCTION dis_test.test_124_todo() OWNER TO postgres;

--
-- Name: FUNCTION test_124_todo(); Type: COMMENT; Schema: dis_test; Owner: postgres
--

COMMENT ON FUNCTION test_124_todo() IS 'Ensure dis.todo functions as expected (2012-03-25)';


--
-- PostgreSQL database dump complete
--

