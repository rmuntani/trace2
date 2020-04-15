# trace2

trace2 is a gem to improve tracing of an application.

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

