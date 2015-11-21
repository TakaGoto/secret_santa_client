Gem::Specification.new do |s|
  s.version         = "0.0.0"
  s.name            = "secret_santa_client"
  s.description     = "Secret Santa Generator"
  s.summary         = "Randomly pairs your list and sends out via text."
  s.authors         = "Taka Goto"
  s.email           = "tak.yuki@gmail.com"
  s.homepage        = 'http://www.gototaka.com'
  s.license         = 'MIT'
  s.files           = %w(README.md)
  s.files           += Dir.glob("lib/**/*")
  s.files           += Dir.glob("spec/**/*")

  s.add_dependency("twilio-ruby", '4.6.2')
end

