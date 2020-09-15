# trace2

[![Build Status](https://travis-ci.com/rmuntani/trace2.svg?token=gGSbpzs6LoB4NK7r6mp6&branch=master)](https://travis-ci.com/rmuntani/trace2)

trace2 generates a graph of relationships between classes that
are used during a runtime.

## Usage

### On the command line

trace2's runner should be used with other Ruby executables:

```bash
trace2 $executable
```

#### Options

```bash
$ trace2 --help
Usage: trace2 [options] RUBY_EXECUTABLE [executable options]
    -h, --help                       Display help
    -v, --version                    Show trace2 version
        --filter FILTER_PATH         Specify a filter file
    -o, --output OUTPUT_PATH         Output path for the report file
    -t, --type TOOLS_TYPE            Type of the tools that will be used to generate the
                                     relationship between classes. Possible values:
                                     ruby or native. Defaults to native.
    -m, --manual                     Don't try to render the relationships graph automatically
```

### On an application

```ruby
require 'trace2'

filter = []
tools = ReportingToolsFactory.new.build(filter)
tools[:class_lister].enable
... # code that will be analyzed
tools[:class_lister].disable
tools[:graph_generator].run('/path/to/file', tools[:class_lister]) # generate a .dot file
                                                                   # with the relationship
                                                                   # between classes
tools[:class_lister].classes_uses # see on Ruby what was registered
```

## Filters

### Format

The filters are used to remove classes uses out of reports or lists that are
registered. A filter is an array of hash, in which each hash can have up to
two keys: `allow` and `reject`. An `allow` key will only allow classes uses
that match the filters that are values of the 'allow'. A `reject` filter will
reject classes uses that match the values of the key.

```ruby
[{ reject: validations }, { allow: validations }]
```

Each validation is an array of hashes, in which eash validation represents
an attribute that should be validated on a class use.

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

### Possible validations

The filters described bellow work both for Ruby and the extension.

|validation name   | effect                                                                     | possible values  |
|------------------|----------------------------------------------------------------------------|------------------|
| name             | check if class name is equal to any of the possible values                 | array of Regex   |
| method           | check if class method is equal to any of the possible values               | array of Regex   |
| path             | check if class path is equal to any of the possible values                 | array of Regex   |
| lineno           | check if the line number is equal to any of the possible values            | array of Integers|
| top_of_stack     | check if class has callees and if the result is equal to the possible value| true or false    |
| bottom_of_stack  | check if class has callers and if the result is equal to the possible value| true or false    |

### Building a filter

A filter that is on .trace2_filter.yml is loaded automatically and
used with trace2's runner. But it can be quite troublesome to generate
a valid YAML file. The following snippet shows a simple method to create
it's content:

```ruby
require 'yaml'
filter = [{ allow: [{ name: ['Tests'] }]}, { allow: [{ name: [/Not/] }, { method: [/yes/, /no/] }] }]

puts filter.to_yaml
```

## Extension

(TODO)

## Development

### Running ruby tests

```bash
script/test_ruby.sh
```

### Running extension's tests

Make sure that `munit.c` and `munit.h` are inside the `ext/test/munit` folder.
Both files can be found at [µnit](https://github.com/nemequ/munit). The
following script may also be used:

```bash
scripts/get_munit.sh
```

After that:

```bash
scripts/test_extension.sh
```

### Running Valgrind

Valgrind is a tool used to detect memory leaks and improper use of memory. To run
it, first install Valgrind. After installing it:

```bash
scripts/run_valgrind.sh
```

### Build and install the gem

```bash
scripts/build_gem.sh
```

### Recompile extension

```bash
scripts/recompile_extension.sh
```

### Update gem's version from the command-line

```bash
scripts/update_version.sh
```
