# How to contribute

## Process

* Fork from the main repo: https://github.com/Imperium/Dis
* have pg_extractor installed: https://github.com/omniti-labs/pg_extractor
* TEST
* Follow the Syntax guide below
* code:
  * develop
  * commit
  * load into PostgreSQL
  * TEST
  * run bin/schema
  * append changes to the commit (changes made by pg_dump)
* TEST
* Submit changes via Pull Requests

## Standards

* tests
  * requests must add new or extend existing tests to cover changes
  * requests must pass all tests
* whitespace
  * spaces (4), no tabs -- except where pg_dump might insist on tabs
  * No trailing whitespace
  * blank lines should have no whitespace
  * all files should have a blank line at the end
* PL/PGSQL
  * all functions must include a documentation block in the function (see dis.assert.sql)
  * all function definitions must include a COMMENT ON FUNCTION that includes a description and date added
  * clarity valued more than brevity
