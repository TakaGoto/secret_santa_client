require 'mobile/noop_logger'
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
      @pairs.each { |pair|
        @twilio_client
          .account
          .messages
          .create(payload(pair[:santa][:number], pair[:person], options[:text_body]))
      }

      @pairs.each { |pair| pair[:person] = Digest::SHA256.hexdigest(pair[:person]) }
      @logger.info(@pairs.to_json)
    end

    def resend_text(name, file_name, text_body)
      log_file = IO.readlines(file_name)
      name_pairs = JSON.parse(log_file[1].split(" : ")[1])
      name_pair = name_pairs.find { |pair| pair["santa"]["name"] == name }
      person = names.find {|name| name_pair["person"] == Digest::SHA256.hexdigest(name)}
      @twilio_client.account.messages.create(payload(name_pair["santa"]["number"], person, text_body))
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
      "Yo Secret Santa, give this whiny little kid #{person} a gift, because we all know #{person} was a bad person this year and will be getting coal from the real Santa."
    end
  end
end
