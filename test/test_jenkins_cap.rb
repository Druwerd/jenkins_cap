require 'helper'

TEST_SETTINGS = YAML.load_file(File.join(File.dirname(__FILE__), "test_settings.yml"))

class TestJenkinsCap < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    Capistrano::JenkinsCap.load_into(@config)
    @config.role :app, TEST_SETTINGS["app"]
    @config.set :deploy_to, TEST_SETTINGS["deploy_to"]
    @config.set :jenkins_host, TEST_SETTINGS["jenkins_host"]
    @config.set :jenkins_job_name, TEST_SETTINGS["jenkins_job_name"]
    @config.set :revision, TEST_SETTINGS["revision"]
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
     @config.jenkins.get_revision_from_build(TEST_SETTINGS["build_number"])
  end
  
  should "check if a build contains the revision number about to be deployed" do
    # no assertion here because can't be sure what we'll get from Jenkins
    @config.jenkins.build_has_revision?(TEST_SETTINGS["build_number"])
  end
  
  should "check if a build passed" do
     # no assertion here because can't be sure what we'll get from Jenkins
     @config.jenkins.build_passed?(TEST_SETTINGS["build_number"])
  end
  
  should "check if a revision passed" do
    # no assertion here because can't be sure what we'll get from Jenkins
    @config.jenkins.revision_passed?
  end
  
  # Unit tests for Capistrano tasks
  should "run build_check task" do
     # need a revision that will pass, otherwise the tests will abort
     #@config.build_check
  end
end
