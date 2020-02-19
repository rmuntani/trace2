# trace2

## Editing rspec executable

```ruby
$LOAD_PATH << 'path/to/trace2'
require 'class_listing'
require 'class_use'
require 'rspec/core'

cl = ClassListing.new
cl.enable
RSpec::Core::Runner.invoke
cl.disable
require 'pry'
binding.pry
```
