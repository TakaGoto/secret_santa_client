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

      names = list.keys
      numbers = list.values

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

    result = JSON.parse(logger.messages.split(" : ")[1])

    result.each do |pair|
      expect(digested_names.include?(pair["person"])).to be true
    end
  end

  it 'finds the digested name and sends text' do
    client = Twilio::REST::Client.new('account-sid', 'auth-token')
    expect(Twilio::REST::Client).to receive(:new).with('account-sid', 'auth-token').and_return(client)
    allow(client.account.messages).to receive(:create)
    logger = Logger.new("file.txt")
    secret_santa = Mobile::SecretSanta.new(:list => list, :logger => logger, :twilio_config => twilio_config)
    name = list.keys[0]
    number = list.values[0]

    secret_santa.pair_list
    secret_santa.send(:text_body => Proc.new {|person| "yar #{person}"})

    file = IO.readlines('file.txt')[1].split(" : ")[1]
    result = JSON.parse(file)
    pair = result.find {|pair| pair["santa"]["name"] == "taka"}
    person = list.keys.find {|name| pair["person"] == Digest::SHA256.hexdigest(name)}

    expect(client.account.messages).to receive(:create)
      .with({:from => 'host-number', :to => number, :body => "yar #{person}"})

    secret_santa.resend_text(name, "file.txt", Proc.new {|person| "yar #{person}"})

    FileUtils.rm "file.txt"
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
  "Yo Secret Santa, give this whiny little kid #{person} a gift, because we all know #{person} was a bad person this year and will be getting coal from the real Santa."
end
