# trace2

[![Build Status](https://travis-ci.com/rmuntani/trace2.svg?token=gGSbpzs6LoB4NK7r6mp6&branch=master)](https://travis-ci.com/rmuntani/trace2)

Generate a graph of relationships between classes that are used during a runtime!

## Installation

```bash
gem install trace2
```

If you want to automatically generate a visual representation
of your graph, install [graphviz](https://graphviz.org/download/).

## Usage

### On the command line

trace2's runner should be used with other Ruby executables:

```bash
trace2 $executable
```

```bash
trace2 rails s
trace2 rubocop -a  # executable's options are supported
trace2 my_script.rb  # ruby scripts are also supported
```

#### Options

```bash
$ trace2 --help
Usage: trace2 [options] RUBY_EXECUTABLE [executable options]
    -h, --help                       Display help
    -v, --version                    Show trace2 version
        --filter FILTER_PATH         Specify a filter file. Defaults to .trace2.yml
    -o, --output OUTPUT_PATH         Output path for the report file. Defaults to
                                     ./trace2_report.yml
    -t, --type TOOLS_TYPE            Type of the tools that will be used to generate the
                                     relationship between classes. Possible values:
                                     ruby or native. Defaults to native.
        --format FORMAT              Format that will be used to render the relationship's
                                     graph. Has no effect if the manual option is set.
                                     Defaults to pdf.
    -m, --manual                     Don't try to render the relationships graph automatically
```

```bash
trace2 --format png rspec spec/trace2/runner_spec.rb  # creates a .dot file and an image
trace2 --manual rspec spec/trace2/runner_spec.rb  # creates only a .dot file
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
                                                                   # with the relationships
                                                                   # between classes
tools[:class_lister].classes_uses # see what was registered
```

## Filters

### Format

The filters are used to remove classes uses out of reports or lists that are
registered. A filter is an array of hashes, in which each hash can have up to
two keys: `allow` and `reject`. An `allow` key will only let through classes uses
that match the filters that are values of the 'allow'. A `reject` filter will
not let through classes uses that match the values of the key.

```ruby
[{ reject: validations }, { allow: validations }]
```

Each validation is an array of hashes, in which eash validation represents
an attribute that should be validated against a class use.

```ruby
[{ allow: [{ method: ['new'], name: ['MyName', 'YourName'] }] }] # checks if class has
                                                                 # a methods named new and
                                                                 # it's name is MyName or YourName
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
  { allow: [{ name: ['MyClass'] }
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
| top_of_stack     | check if class has callees and if the result is equal to the expected value| true or false    |
| bottom_of_stack  | check if class has callers and if the result is equal to the expected value| true or false    |

### Building a filter

A filter that is on .trace2_filter.yml is loaded automatically and
used with trace2's runner, but it can be quite troublesome to generate
a valid YAML file. The following snippet shows a simple procedure to create
it's content:

```ruby
> require 'yaml'
> filter = [{ allow: [{ name: ['Tests'] }]}, { allow: [{ name: [/Not/] }, { method: [/yes/, /no/] }] }]

> puts filter.to_yaml
---
- :allow:
  - :name:
    - Tests
- :allow:
  - :name:
    - !ruby/regexp /Not/
  - :method:
    - !ruby/regexp /yes/
    - !ruby/regexp /no/
```

## Native and Ruby code

The first few tests that involved Ruby code showed that it was too slow for
the main goal of this gem. Running rubocop on this project is enough to prove
it:

```ruby
trace2 rubocop --type ruby
```

Despite that, to allow users of this gem to extend it and have some understanding
of how it works, some classes were written both in Ruby and in native code. The
classes that were implemented both in C and Ruby are EventProcessorC and EventProcessor,
as well as GraphGenerator and GraphGeneratorC.

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
