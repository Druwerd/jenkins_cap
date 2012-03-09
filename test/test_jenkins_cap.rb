require 'helper'

class TestJenkinsCap < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    Capistrano::JenkinsCap.load_into(@config)
    @config.role :app, "localhost"
    @config.set :deploy_to, "/tmp"
    @config.set :jenkins_host, "http://cijoe.gnmedia.net"
    @config.set :jenkins_job_name, "puppet-dev-quick-test"
    @config.set :revision, "1"
  end
  
  # Unit tests for helper functions
  #
  should "get a successful JSON response" do
    assert @config.jenkins.json_request("#{@config.jenkins_host}/api/json")
  end
  
  should "get an Array of build numbers" do
     assert_kind_of Array, @config.jenkins.get_builds
  end
  
  should "get a revision number (or nil) without error" do
     # no assertion here because can't be sure what we'll get from Jenkins
     @config.jenkins.get_revision_from_build("1")
  end
  
  should "check if a build contains the revision number about to be deployed" do
    # no assertion here because can't be sure what we'll get from Jenkins
    @config.jenkins.build_has_revision?("1")
  end
  
  should "check if a build passed" do
     # no assertion here because can't be sure what we'll get from Jenkins
     @config.jenkins.build_passed?("1")
  end
  
  should "chekc if a revision passed" do
    # no assertion here because can't be sure what we'll get from Jenkins
    @config.jenkins.revision_passed?
  end
  
  # Unit tests for Capistrano tasks
end
