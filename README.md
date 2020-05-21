# trace2

trace2 is a gem to improve tracing of an application.

## Usage

```ruby
filter = []
class_lister = Trace2::ClassLister.new(filter: filter)
class_lister.enable
# code that should generate a list of classes' uses
class_lister.disable

class_lister.classes_uses # an array of Trace2::ClassUse
```

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

## Possible filters

The filters described bellow work both for Ruby and the extension. Bear in mind
that Ruby currently has more validations than the extension.

|validation name   | effect                                                                     | possible values  |
|------------------|----------------------------------------------------------------------------|------------------|
| name             | check if class name is equal to any of the possible values                 | array of Strings |
| method           | check if class method is equal to any of the possible values               | array of Strings |
| path             | check if class path is equal to any of the possible values                 | array of Strings |
| lineno           | check if the line number is equal to any of the possible values            | array of Integers|
| top_of_stack     | check if class has callees and if the result is equal to the possible value| true or false    |
| bottom_of_stack  | check if class has callers and if the result is equal to the possible value| true or false    |

## Running ruby tests

```
script/test_ruby.sh
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

## Running Valgrind

Valgrind is a tool used to detect memory leaks and improper use of memory. To run
it, first install Valgrind. After installing it:

```
scripts/run_valgrind.sh
```

## Build and install the gem
```
scripts/build_gem.sh
```
