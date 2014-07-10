Gem::Specification.new do |s|
  s.name        = 'senml_parser'
  s.version     = '0.0.1'
  s.date        = '2013-10-23'
  s.summary     = ""
  s.description = "A parser for SenML"
  s.authors     = ["GOBI", "Malte Husmann"]
  s.email       = 'gobi@tzi.de'
  s.files       = ["lib/senml_parser.rb"]
  s.homepage    = 'http://gobi.tzi.de'
  s.license     = 'MIT'

  s.add_dependency('json')
  s.add_dependency('cbor')
end