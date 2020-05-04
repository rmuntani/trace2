# trace2

trace2 is a gem to improve tracing of an application.

## Filter formats

ruby's `QueryUse` is a class that checks if a class matches filters. The filter
should be an array of hashes. Each hash can have one of two keys: `allow` and
`reject`. An `allow` key will only allow classes uses that match all filters
that are values of the key. A `reject` filter will reject classes uses that
don't match the values of the key.

```ruby
[{ reject: value }, { allow: values }]
```

Each value is also an array of hashes. Each hash has keys that are names of
ClassUse's attributes. The values are arrays of strings that the attribute
should match.

```ruby
[{ allow: [{ method: ['new'], name: ['MyName', 'YourName'] }] }]
```

To execute an OR statement:

```ruby
[{ allow: [{ method: ['new'] }, { name: ['MyName'] }] }] # class use has method
                                                         # 'new' or name 'MyName'
```

To execute an AND statement:
```ruby
# class use has method `new` and name `MyClass`
[
  { allow: [{ method: ['new'] } },
  { reject: [{ name: ['MyClass'] }
]
```

`query_use_spec` has more examples of how to write a filter.

## Running ruby tests

```
rake compile && rspec
```

## Running extension tests

Make sure that `munit.c` and `munit.h` are inside the `ext/test/munit` folder. 
Both files can be found at [µnit](https://github.com/nemequ/munit). The 
following script may also be used:

```
scripts/get_munit.sh
```

After that:

```
scripts/test_extension.sh
```

