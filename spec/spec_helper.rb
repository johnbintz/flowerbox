require 'simplecov'
SimpleCov.start

require 'mocha'
require 'fakefs/spec_helpers'

require 'flowerbox'

RSpec.configure do |c|
  c.mock_with :mocha
end
