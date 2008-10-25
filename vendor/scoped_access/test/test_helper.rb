def __DIR__; File.dirname(__FILE__); end

$:.unshift(__DIR__ + '/../lib')
# begin
#   require 'rubygems'
# rescue LoadError
  $:.unshift(__DIR__ + '/../../../rails/activerecord/lib')
  $:.unshift(__DIR__ + '/../../../rails/activesupport/lib')
  $:.unshift(__DIR__ + '/../../../rails/actionpack/lib')
#end
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'

config = YAML::load_file(__DIR__ + '/database.yml')
ActiveRecord::Base.logger = Logger.new(__DIR__ + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])


# create tables
load(__DIR__ + "/schema.rb")

# insert sample data to the tables from 'fixtures/*.yml'
Test::Unit::TestCase.fixture_path = __DIR__ + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
Test::Unit::TestCase.use_instantiated_fixtures  = false

# for controller test
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'

ActionController::Base.ignore_missing_templates = true
ActionController::Routing::Routes.reload rescue nil
class ActionController::Base; def rescue_action(e) raise e end; end

include ScopedAccess

