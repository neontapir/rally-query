# rubyStoryQuery

## Installation

Install Ruby 2.0+ if you haven't done so already.

Then,

    # gem install bundle
    # bundle install
    
This will get you all the dependencies you need. I need to run these commands with `sudo` on my system, but it will
prompt you if you need it.

## Usage

### Single story

    ./story_query.rb US12345

### Data dump

    ./story_query.rb -i input.txt -x > output.csv