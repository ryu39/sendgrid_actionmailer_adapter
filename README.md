# SendgridActionMailerAdapter

[![Build Status](https://travis-ci.org/ryu39/sendgrid_actionmailer_adapter.svg?branch=master)](https://travis-ci.org/ryu39/sendgrid_actionmailer_adapter)
[![Code Climate](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter/badges/gpa.svg)](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter)
[![Test Coverage](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter/badges/coverage.svg)](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter/coverage)
[![Issue Count](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter/badges/issue_count.svg)](https://codeclimate.com/github/ryu39/sendgrid_actionmailer_adapter)

A ActionMailer adapter using [SendGrid Web API v3](https://sendgrid.com/docs/API_Reference/Web_API_v3/index.html).

## Requirements

* Ruby >= 2.3.0
* [sendgrid-ruby](https://github.com/sendgrid/sendgrid-ruby) >= 4.0


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sendgrid_actionmailer_adapter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sendgrid_actionmailer_adapter


## Usage

First, in your `config/application.rb` or `config/environments/*.rb`, 
set `SendgridActionMailerAdapter::DeliveryMethod` to `config.action_mailer.delivery_method`.

```ruby

Rails.application.configure do
  # :
  config.action_mailer.delivery_method = SendGridActionMailerAdapter::DeliveryMethod
  # :
end

```

Next, create an initializer file for this gem and add to your `config/initializers` directory.
Note that the `api_key` value is required, so issue your api_key at [SendGrid Settings API Keys](https://app.sendgrid.com/settings/api_keys).

```ruby
SendGridActionMailerAdapter.configure do |config|
  # required
  config.api_key = ENV['YOUR_SENDGRID_API_KEY']
  
  # optional(SendGrid)
  config.host = 'host'
  config.request_headers = { key: 'val' }
  config.version = 'v3'
  
  # optional(Retry)
  config.retry_max_count = 3
  config.retry_wait_seconds = 3.0
end
```

Then, you can send emails from ActionMailer class. 

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com',
          reply_to: 'no-reply@example.com'

  def test_mail
    mail(to: 'test@example.com', subject: 'Test mail')
  end
end

class TestMailsController < ApplicationController
  def create
    TestMailer.test_mail.deliver_now 
  end
end
```

### SendGrid features

#### categories

You can set `categories` parameters via `.default` or `#mail` method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com',
          reply_to: 'no-reply@example.com',
          categories: ['Test']

  def test_mail
    mail(to: 'test@example.com', subject: 'Test mail', categories: ['Test1', 'Test2'])
  end
end
```

#### send_at 

You can set 'send_at' parameter for scheduled emails.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com',
          reply_to: 'no-reply@example.com'

  def test_mail
    mail(to: 'test@example.com', subject: 'Test mail', send_at: 1.hour.since)
  end
end
```

#### Supported and unsupported Web API attributs

##### Supported

* personalizations
  * to
  * cc
  * bcc
* from
* reply_to
* subject
* content
* attachments
* categories
* send_at

##### Unsupported

* personalizations
  * subject
  * headers
  * substitutions
  * custom_args
  * send_at
* template_id
* sections
* headers
* custom_args
* batch_id
* asm
* in_pool_name
* mail_settings
* tracking_settings


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rake` to run the rubocop and tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryu39/sendgrid_actionmailer_adapter.
This project is intended to be a safe, welcoming space for collaboration, 
and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
