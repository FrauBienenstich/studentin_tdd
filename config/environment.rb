require 'yaml'
require 'awesome_print'
# puts __FILE__
# puts File.expand_path(__FILE__)
# puts File.dirname(File.expand_path(__FILE__))


env = ENV["STUDENT_ENV"] || "development"

config_file_name =  File.join(File.dirname(File.expand_path(__FILE__)), env,'config.yml')

CONFIG = YAML::load_file(config_file_name)
  
ap CONFIG["database"]["name"]
