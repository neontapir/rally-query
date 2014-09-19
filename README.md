# rubyStoryQuery

## Installation

Install Ruby 2.0+ if you haven't done so already.

Then,

    # gem install bundle
    # bundle install
    
This will get you all the dependencies you need. I need to run these commands with `sudo` on my system, but it will
prompt you if you need it.

## Usage

### To see all the options

    ./story_query.rb --help

### Single story

    ./story_query.rb US12345

### Data dump

    ./story_query.rb -i input.txt -x > output.csv
    
## Extension points

### Add a new report type

The easiest way would be copy and existing flow. Copy the format Ruby class and the Mustache template. Create a RSpec 
specification by copying one of the other ones.

You'll also need to add a reference to your formatter class to work_item_formatter.rb

### Add a new Kanban state

Kanban states are defined in `WorkItemState`. The "weight" value is used for sorting. There is a concept of a canonical
state -- a category of sorts -- that's used to group hours into buckets.

### Display a field in a report

To do so, you'll need to modify the "view" and the "model". So, to display on the screen, modify 
`work_item_screen_format.rb` to make it available to Mustache, then in the associated Mustache file to define where to
render the value.

The export report contains more fields than the screen one. These are exposed by mixing in `work_item_export_extensions.rb`
into the export format class.

Utility functions used by all reports like date formatters are included in `work_item_base_format.rb`.

## Development notes

### Guard support

Use `bundle exec guard` to run the RSpec tests whenever a Ruby file is altered.

### Rake support

Running `rake` will execute all the RSpec tests in a random order.

### SimpleCov support

Run `COVERAGE=yes rspec .simplecov spec/*_spec.rb` to generate a code coverage report. 
Then open `coverage/index.html` to navigate the report.