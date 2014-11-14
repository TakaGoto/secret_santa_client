require 'secret_santa'

describe SecretSanta do
  describe "#pair" do
    it "randomly pairs up people" do
      people = {
        :taka => "taka@gmail.com",
        :emmanuel => "emmanuel@gmail.com",
        :tania => "tania@gmail.com"
      }

      result = SecretSanta.pair(people)

      result.each do |person|
        expect(person[:pair]).to_not be nil
        expect(person[:name]).to_not eq(person[:pair])
      end
    end

    it "blacklists pairs of people" do
      people = {
        :taka => "taka@gmail.com",
        :emmanuel => "emmanuel@gmail.com",
      }

      expect(SecretSanta.pair(people, {:taka => :emmanuel})).to eq([])
    end
  end
end
