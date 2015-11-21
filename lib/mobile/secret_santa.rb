require 'logger'
require 'json'
require 'digest'
require 'twilio-ruby'

module Mobile
  class SecretSanta
    attr_reader :names, :pairs, :logger

    def initialize(options)
      @list = options[:list]
      @logger = options[:logger] || NoopLogger.new
      @host_number = options[:twilio_config][:host_number]
      @twilio_client = Twilio::REST::Client.new(options[:twilio_config][:account_sid], options[:twilio_config][:auth_token])
    end

    def pair_list
      shuffled_names = names.shuffle
      @pairs = shuffled_names.each.with_index.reduce([]) do |pair, (person, index)|
        pair << {
          :santa => {
            :name => person, :number => @list[person]
          },
          :person => shuffled_names[next_person(index)]
        }
        pair
      end
    end

    def send(options = {})
      pairs = @pairs.clone
      pairs.each { |pair| pair[:santa][:name] = Digest::SHA256.hexdigest(pair[:santa][:name]) }
      @logger.info(pairs.to_json)

      pairs.each { |pair|
        @twilio_client
          .account
          .messages
          .create(payload(pair[:santa][:number], pair[:person], options[:text_body]))
      }
    end

    def names
      @names ||= @list.keys
    end

    private

    def payload(number, person, text_body)
      {
        :from => @host_number,
        :to => number,
        :body => text_body != nil ? text_body.call(person) : default_text_body(person)
      }
    end

    def next_person(index)
      (index + 1) == names.size ? 0 : index + 1
    end

    def default_text_body(person)
      "Yo Secret Santa, give this whiny little kid #{person} a gift, because we all know #{person} was a bad person this year and will be getting coal from the real Santa. Sincerly, The Cool Tak's Secret Santa #{Time.now.year}."
    end
  end
end

class NoopLogger
  def initialize; end
  def info(body); end
end
