# MomentumApi

[![Code Climate](https://codeclimate.com/github/discourse/discourse_api.png)][codeclimate]

[codeclimate]: https://codeclimate.com/github/discourse/discourse_api

Momentum's custom community code.

## Installation

Add this line to your application's Gemfile for the required Discourse API gem:

    gem 'discourse_api'

And then execute:

    $ bundle


## Usage

Including membership management and many other functions to keep Momentum Owners informed.

- _master/scan_hourly.rb controls auto run of all tasks.

- _master/apply_to_users.rb cycles thru all members to run currently 6 different tasks.



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

Unit Tests are designed to run without a Discourse instance, but you may also test against an instance with:

1. Install discourse locally
2. Inside of your discourse directory, run: `bundle exec rake db:api_test_seed`
3. Start discourse: `bundle exec rails s`
4. Install bundler in the discourse_api directory, run `gem install bundler`
5. Inside of your discourse_api directory, run: `bundle exec rspec spec/`

## Issues

Issues are active, so feel free to submit on the Issues tab above.
