Secret Santa Client
============

## About

Secret Santa Client provides an anonymous way to randomly pair for Secret Santa.

## Usage

Uses Twilio API to send the texts. If you want to use this you will need a [Twilio](http://www.twilio.com) account.

Example:

```

require 'mobile/secret_santa'

list = {
  "Tak"     => "+13302370308",
  "Sarah"   => "+12079327441",
  "Tania"   => "+11306358563",
  "Clint"   => "+12212318187",
  "Lydia"   => "+19439348292",
  "Donovan" => "+16305302371"
}

logger = Logger.new("2015_secret_santa.txt")

twilio_config = {
  :account_sid => 'account-sid',
  :auth_token => 'auth-token',
  :host_number => 'your-twilio-host-number'
}

secret_santa = Mobile::SecretSanta.new(:list => list, :logger => logger, :twilio_config => twilio_config)

secret_santa.pair_list.send

you can create your own text body but the default will look something like this:
  Yo Secret Santa, give this whiny little kid #{person} a gift, because we all know #{person} was a bad person this year and will be getting coal from the real Santa.

You can pass in a block if you don't want to use the default text body

```
secret_santa.pair_list.send(:text_body => Proc.new {|person| "hello #{person}."})
```

## Resending text

If for some reason someone didn't receive a text, no worries. you can resend the text. You'll need the log file name and the name of the person who didn't get a text:

```
  secret_santa.resend_text("Tak", "2015_secret_santa.txt")
```

## Logging

Logging is optional, but in case something goes wrong, for example someone didn't get a text, you can log the pairing. The names of the secret santa is hexdigested, in case you don't want to accidently see who everyone has.

## Features

1. Twilio Integration
2. Logging
1. Resend text

## Testing

1. `bundle install`
2. `rspec`

## Future Features

2. Blacklist pairs.
3. Any other thoughts?
