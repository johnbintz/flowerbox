require 'flowerbox/test_environment/base'
require 'jasmine-core'
require 'yaml'

module Flowerbox
  module TestEnvironment
    class Jasmine < Base
      def self.transplant(dir)
        if File.file?(jasmine_yml = File.join(dir, 'support/jasmine.yml'))
          puts "Transplanting #{jasmine_yml} into Flowerbox..."

          config = [
            %{f.test_with :jasmine},
            %{f.run_with :firefox},
            %{f.report_with :verbose}
          ]

          YAML.load_file(jasmine_yml).each do |key, value|
            case key
            when 'src_dir'
              [ value ].flatten.each do |dir|
                config << %{f.asset_paths << "#{dir}"}
              end
            when 'src_files'
              [ value ].flatten.each do |file|
                config << %{f.additional_files << "#{file}"}
              end
            when 'helpers'
              [ value ].flatten.each do |pattern|
                Dir[File.join(dir, pattern)].each do |file|
                  config << %{f.additional_files << "#{file.gsub("#{dir}/", '')}"}
                end
              end
            when 'spec_files'
              [ value ].flatten.each do |pattern|
                config << %{f.spec_patterns << "#{pattern}"}
              end
            end
          end

          File.open(target = File.join(dir, 'spec_helper.rb'), 'wb') do |fh|
            fh.puts "Flowerbox.configure do |f|"
            config.each do |line|
              fh.puts "  #{line}"
            end
            fh.puts "end"
          end

          puts "#{target} created. Run your tests with:"
          puts "  flowerbox test #{dir}"
        end
      end

      def inject_into(sprockets)
        sprockets.append_path(::Jasmine::Core.path)

        super
      end

      def global_system_files
        %w{jasmine.js flowerbox/jasmine.js}
      end

      def runner_system_files
        [ "flowerbox/jasmine/#{@runner.type}.js" ]
      end

      def start
        super

        <<-JS
if (typeof context != 'undefined' && typeof jasmine == 'undefined') {
  jasmine = context.jasmine;
}

jasmine.getEnv().addReporter(new jasmine.FlowerboxReporter());

jasmine.getEnv().execute();
JS
      end
    end
  end
end

