# Dis ChangeLog

## v 0.4.0

### Framework

* Test Runners will append `_test` to any schema name passed as a parameter that does not end with `_test` AND will prepend `test_` to any test name passed as a parameter that does not start with `test_`.
  * dis.run_tests(schema text DEFAULT null, module text DEFAULT null, submodule text DEFAULT null)
  * dis.run_test(schema text, name text)
  * dis.test_wrapper(schema text, name text)

### Assertions

* dis.compare(have anyelement, operator text, against anyelement, message text DEFAULT '')
* dis.compare(have anyelement, operator text, against dis.mold, message text DEFAULT '')
* dis.raises(call text, want text DEFAULT NULL, message text DEFAULT '')
* dis.not_raises(call text, notwant text DEFAULT NULL, message text DEFAULT '')
* dis.no_result(call text, message text DEFAULT '')
* dis.has_result(call text, message text DEFAULT '')
* dis.one_result(call text, message text DEFAULT '')

### Helper Functions

* dis.__count(call text)
* dis.mold(value anyelement)

### Types

* dis.mold(value text, type regtype)

### Tests

* dis_test.test_070__count
* dis_test.test_180_compare
* dis_test.test_185_compare
* dis_test.test_220_raises
* dis_test.test_225_not_raises
* dis_test.test_240_no_result
* dis_test.test_242_has_result
* dis_test.test_244_one_result

## v 0.3.0

### Framework

* FIX: gensql - handle parameters properly and add some diagnostic output
* FIX: dis.run_tests - run right with module or module and submodule parameters

### Report

* FIX: summary views - change the status column name from status_agg to status
* XML Reporting functions
  * dis_v1.run_tests_xml(schema text DEFAULT null, module text DEFAULT null, submodule text DEFAULT null)
  * dis_v1.schemata_summary_xml()
  * dis_v1.schema_summary_xml(schema text, detail boolean DEFAULT false)
  * dis_v1.module_summary_xml(schema text, module text, detail boolean DEFAULT false)
  * dis_v1.submodule_summary_xml(schema text, module text, submodule text, detail boolean DEFAULT false)
  * dis_v1.test_report_xml(test_schema text, test_name text, detail boolean DEFAULT false) - Update

## v 0.2.0

### Famework

* Break out database extraction by schema
* Add License

### Assertions

* dis.ok(message text DEFAULT '')
* dis.fail(message text DEFAULT '')
* dis.same(have anyelement, want anyelement, message text DEFAULT '')
* dis.not_same(have anyelement, notwant anyelement, message text DEFAULT '')
* dis.greater(have anyelement, want anyelement, message text DEFAULT '')
* dis.greater_equal(have anyelement, want anyelement, message text DEFAULT '')
* dis.less(have anyelement, want anyelement, message text DEFAULT '')
* dis.less_equal(have, want, message DEFAULT '')
* dis.contains (have anyarray, want anyarray, message DEFAULT '')
* dis.contains (have anyarray, want anynonarray, message DEFAULT '')
* dis.not_contains (have anyarray, want anyarray, message DEFAULT '')
* dis.not_contains (have anyarray, want anynonarray, message DEFAULT '')
* dis.in_array (have anyarray, want anyarray, message DEFAULT '')
* dis.in_array (have anynonarray, want anyarray, message DEFAULT '')
* dis.not_in_array (have anyarray, want anyarray, message DEFAULT '')
* dis.not_in_array (have anynonarray, want anyarray, message DEFAULT '')
* dis.match (have text, regex text, message DEFAULT '')
* dis.imatch (have text, regex text, message DEFAULT '')
* dis.no_match (have text, regex text, message DEFAULT '')
* dis.no_imatch (have text, regex text, message DEFAULT '')
* dis.type (have anyelement, want regtype, message DEFAULT '')
* dis.not_type (have anyelement, notwant regtype, message DEFAULT '')
* FIX: dis.assert

### Tests

* dis_test.test_120_ok
* dis_test.test_122_fail
* dis_test.test_124_todo
* dis_test.test_126_skip
* dis_test.test_130_same
* dis_test.test_135_not_same
* dis_test.test_140_greater
* dis_test.test_142_greater_equal
* dis_test.test_144_less
* dis_test.test_146_less_equal
* dis_test.test_150_contains
* dis_test.test_152_not_contains
* dis_test.test_154_in_array
* dis_test.test_156_not_in_array
* dis_test.test_160_match
* dis_test.test_162_no_match
* dis_test.test_164_imatch
* dis_test.test_166_no_imatch
* dis_test.test_170_type
* dis_test.test_175_not_type

## v 0.1.0

### Framework

* Execution
** dis.result - table to store current results
** dis.run_tests(schema text DEFAULT null, module text DEFAULT null, submodule text DEFAULT null)
** dis.run_test(test_schema, test_name)
** dis.test_wrapper(test_schema, test_name)
** dis.tally(tallies dis.score[]) - helper to summarize test result from assertion scores
* Management
** bin/schema - extract code from database
** bin/gensql - package sql for updates
* Summary Views: 
  * dis.schema_summary - summarize last results by schema
  * dis.module_summary - summarize last results by module
  * dis.submodule_summary - summarize last results by submodule
  * dis.test - all possible tests
* History of all test runs

### Assertions

* dis.assert(assertion boolean, message DEFAULT '', detail text[] DEFAULT '{}':text[])
* dis.skip(message text DEFAULT '')
* dis.todo(message text DEFAULT '')

### Reporting

* dis_v1.test_report_xml(test_schema text, test_name text)

### Types

* dis.score(status text, message text, detail text[])

### Examples

* dis_test.test_alpha
* dis_test.test_beta
* dis_test.test_gamma
* dis_test.test_delta
* dis_test.test epsilon


