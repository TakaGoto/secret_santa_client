require 'mobile/secret_santa'

require 'json'
require 'logger'
require 'digest'
require 'twilio-ruby'

describe Mobile::SecretSanta do
  let(:list) { {"taka" => "123-123-1234", "dave" => "321-321-4321", "eric" => "098-098-0987", "joe" => "456-456-4567"} }
  let(:logger) { TestLogger.new }
  let(:twilio_config) { {:account_sid => 'account-sid', :auth_token => 'auth-token', :host_number => 'host-number'} }
  let(:santa) { Mobile::SecretSanta.new(:list => list, :logger => logger, :twilio_config => twilio_config) }

  describe '#pair_list' do
    it 'pairs up people' do
      results = santa.pair_list

      expect(results.length).to eq(4)

      names = ["taka", "dave", "eric", "joe"]
      numbers = ["123-123-1234", "321-321-4321", "098-098-0987", "456-456-4567"]

      results.each do |result|
        expect(numbers).to include(result[:santa][:number])
        expect(names).to include(result[:santa][:name])
        expect(names).to include(result[:person])
      end
    end

    it 'shuffles the list' do
      expect(santa.names).to receive(:shuffle).and_return([])
      santa.pair_list
    end
  end

  it 'uses NoOp Logger if no logger is passed' do
    secret_santa = Mobile::SecretSanta.new(:list => {}, :logger => nil, :twilio_config => twilio_config)

    expect(secret_santa.logger.class).to be(NoopLogger)
  end

  it 'sends a text message' do
    client = Twilio::REST::Client.new('account-sid', 'auth-token')
    expect(Twilio::REST::Client).to receive(:new).with('account-sid', 'auth-token').and_return(client)

    santa.pair_list

    santa.pairs.each do |pair|
      expect(client.account.messages).to receive(:create)
        .with({:from => 'host-number', :to => pair[:santa][:number], :body => text_body(pair[:person])})
    end

    santa.send
  end

  it 'can have optional block sent for building dynamic text body' do
    client = Twilio::REST::Client.new('account-sid', 'auth-token')
    expect(Twilio::REST::Client).to receive(:new).with('account-sid', 'auth-token').and_return(client)

    santa.pair_list

    santa.pairs.each do |pair|
      expect(client.account.messages).to receive(:create)
        .with({:from => 'host-number', :to => pair[:santa][:number], :body => "yar #{pair[:person]}"})
    end

    santa.send(:text_body => Proc.new {|person| "yar #{person}"})
  end

  it 'logs the pairing with digested names' do
    client = Twilio::REST::Client.new('account-sid', 'auth-token')
    expect(Twilio::REST::Client).to receive(:new).with('account-sid', 'auth-token').and_return(client)
    allow(client.account.messages).to receive(:create)

    santa.pair_list
    santa.send

    digested_names = list.keys.reduce([]) do |names, name|
      names << Digest::SHA256.hexdigest(name)
      names
    end

    digested_names.each do |digested_name|
      expect(logger.messages).to include(digested_name)
    end
  end
end

class TestLogger < Logger
  def initialize
    @stringIO = StringIO.new
    super(@stringIO)
  end

  def messages
    @stringIO.string
  end
end

def text_body(person)
  "Yo Secret Santa, give this whiny little kid #{person} a gift, because we all know #{person} was a bad person this year and will be getting coal from the real Santa. Sincerly, The Cool Tak's Secret Santa 2015."
end
