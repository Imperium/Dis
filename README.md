# DIS - PostgreSQL Unit Testing

Simple framework for unit testing that combines an execution rollback guarantee with detailed reporting on each test.

## Why Not pgTAP

pgTAP is a rich framework with a large number of useful tests that can be used with other components of the TAP ecosystem.  The weakness of pgTAP is that it relies on handlers outside the database reading the results before the rollback occurs.  This may be useful for a perl/python/php application that wants to include some database tests into its TAP testing, but if the database is the application why would you peform the testing outside of the database.  And to me the fundimental structure seems unsafe because the rollback relies on the proper construction of the test script.

## Why Not Epic

Fundamentally, I lake the eligance of the Epic testing framework since each test performs its actions and then reports status via an Exception that rollsback all actions peformed by the test.  This is why Dis is uses the same basic operational structure. The weakness of Epic is that it relies too much on the test function not having any bugs and being able to properly summarize any assertions/subtests performed in the test function.  The TAP paradigm does not trust the test script to do the right thing, it reports on each assertion/subtest and ensures that the proper number of tests were run.

Additionally Epic has been stale for a few years...

## Best of Both Worlds

Dis combines the detailed reporting and checks that pgTap provides with the in database execution model of Epic.

### Example Test Function
    CREATE OR REPLACE FUNCTION app_test.test_alpha RETURNS void
        LANGUAGE plpgsql
        VOLATILE
        SECURITY INVOKER
        AS $_$
    -- Plan: 1
    DECLARE
        _scores   dis.score[] := '{}'::dis.score[];
    BEGIN
        _scores := ARRAY[
            dis.assert(TRUE, 'This is a test'),
            dis.assert(FALSE, 'Oops this will fail'),
            dis.assert(TRUE, 'This also works')
        ];
        PERFORM dis.tally(_scores);
    END;
    $_$;

