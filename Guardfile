# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :rspec do
  guard 'rspec', :version => 2 do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }
  end
end

group :wip do
  guard 'cucumber', :cli => '-p wip' do
    watch(%r{^features/.+\.feature$})
    watch(%r{^features/support/.+$})          { 'features' }
    watch(%r{^features/step_definitions/.*$}) { 'features' }
  end
end
