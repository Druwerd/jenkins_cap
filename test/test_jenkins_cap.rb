require 'helper'

class TestJenkinsCap < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    Capistrano::JenkinsCap.load_into(@config)
    @config.role :app, "localhost"
    @config.set :deploy_to, "/tmp"
    @config.set :jenkins_host, "http://cijoe.gnmedia.net"
    @config.set :jenkins_job_name, "puppet-dev-quick-test"
    @config.set :current_revision, "1"
  end
  
  should "get a successful JSON response" do
    assert @config.jenkins.json_request("#{@config.jenkins_host}/api/json")
  end
  
  should "get an Array of build numbers" do
     assert_kind_of Array, @config.jenkins.get_builds
  end
end
