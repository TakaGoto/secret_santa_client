Secret Santa Client
============

## About

Use this to randomly generator pairing of people for Secret Santa and send texts.

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

```

## Logging

Logging is optional, but in case something goes wrong, for example someone didn't get a text, you can log the pairing. The names of the secret santa is hexdigested, in case you don't want to accidently see who everyone has.

## Features

1. Twilio Integration
2. Logging

## Text Body

You can pass in a block if you don't want to use the default text body

```
secret_santa.pair_list.send(:text_body => Proc.new {|person| "hello #{person}."})
```

## Future Features

1. Resend email by phone number by looking through logs
2. Blacklist pairs.
3. Any other thoughts?
