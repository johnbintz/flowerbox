# A sample Guardfile
# More info at https://github.com/guard/guard#readme


guard 'compass', :configuration_file => 'config/compass.rb' do
  watch(%r{^sass/(.*)\.s[ac]ss$})
end

guard 'haml', :input => '_layouts/haml', :output => '_layouts' do
  watch(/^.+(\.html\.haml)/)
end
