# trace2

trace2 is a gem to improve reading the stack that resulted into a call. It 
provides a specific syntax to query for the use of certain classes, methods or
paths.

## Query

### Filter parameters syntax

The parameter used to filter must be an array of hashes. Every hash should
have as it's key :allow or :reject.

Example:
```
[allow: [], reject: []]
```

The filters are applied sequentially.

To make an AND query, the following
are equivalent:
```
[
  allow: [ something: [] ], 
  allow: [ anything: [] ]
]

[ 
  allow: [{ something: [], anything: [] }]
]
```

An OR can be written as:
```
[ 
  allow: [ something: [], anything: [] ]
]
```

A NOT is achieved using reject:

```
[
  reject: [ something: []]
]
```

## Editing rspec executable

```ruby
$LOAD_PATH << 'path/to/trace2'
require 'class_lister'
require 'class_use'
require 'rspec/core'

cl = ClassLister.new
cl.enable
RSpec::Core::Runner.invoke
cl.disable
require 'pry'
binding.pry
```
