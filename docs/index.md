# Assertions

### Faux:

* dis.ok(:message = '')
* dis.fail(:message = '')
* dis.skip(:message = '')
* dis.todo(:message = '')

### Boolean:

* dis.assert(:assertion, :message = '', :detail = '{}'::text[])

### Same:

* dis.same(:have, :want, :message = '')
* dis.not_same(:have, :notwant, :message = '')

### Relative:

* dis.greater(:have, :want, :message = '')
* dis.greater_equal(:have, :want, :message = '')
* dis.less(:have, :want, :message = '')
* dis.less_equal(:have, :want, :message = '')

### Array:

* dis.contains(:have, :want, :message = '')
* dis.not_contains(:have, :want, :message = '')
* dis.in_array(:have, :want, :message = '')
* dis.not_in_array(:have, :want, :message = '')

### Match:

* dis.match(:have, :regex, :message = '')
* dis.imatch(:have, :regex, :message = '')
* dis.no_match(:have, :regex, :message = '')
* dis.no_imatch(:have, :regex, :message = '')

### Type:

* dis.type(:have, :want, :message = '')
* dis.not_type(:have, :notwant, :message = '')