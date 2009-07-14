require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'logging'
require 'logger'
require 'package'

module ProgramOptions
  def self.handle_options(args)
    options = OpenStruct.new
    options.debug = false
    options.list_packages = nil

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: package [options] <package> <command>"
      opts.separator ""
      opts.separator "Specific Options:"
      
      opts.on("-d", "--debug", "Produce more logging output") do |debug|
        Logging.logger.level = Logger::DEBUG
      end

      opts.on("-l", "--list", "List All Available Packages") do |list|
        Packages.registered_packages.each_key do |name|
          puts name
        end
        exit
      end

      opts.on("-c", "--commands [PACKAGE]", "List Commands for Package") do |package|
        begin 
          p = Packages.lookup(package.intern)
          methods = p.methods - Package.instance_methods
          for m in methods
            puts m 
          end
        rescue Exception => e
          error e.message
        end
        exit
      end
      
      opts.on_tail("-h", "--help", "Show this message") do 
        puts opts
        exit 
      end
    end
    
    begin
      parser.parse!(args)
    rescue
      puts parser
      exit
    end
    options
  end
end
