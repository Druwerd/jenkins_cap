require 'json'
require 'term/ansicolor'
require 'capistrano'

class String
  include Term::ANSIColor
end

module Capistrano
  module JenkinsCap
    
    def json_request(url)
      response = `wget -q -O - #{url}`
      JSON.load(response)
    end

    def get_builds()
      json_results = json_request("#{jenkins_host}/job/#{jenkins_job_name}/api/json")
      builds = []
      json_results['builds'].each{|b| builds << b['number']}
      builds
    rescue NoMethodError => e
      puts "WARNING: #{e}".yellow
    end

    def get_revision_from_build(build_number)
      json_results = json_request("#{jenkins_host}/job/#{jenkins_job_name}/#{build_number}/api/json")
      json_results["actions"].each do |entry|
        return entry['lastBuiltRevision']['SHA1'] if !entry['lastBuiltRevision'].nil?
      end
      nil
    rescue NoMethodError => e
      puts "WARNING: #{e}".yellow
    end

    def build_has_revision?(build_number)
      build_revision = get_revision_from_build(build_number)
      real_revision != nil && build_revision.to_i == real_revision.to_i
    end

    def build_passed?(build_number)
      json_results = json_request("#{jenkins_host}/job/#{jenkins_job_name}/#{build_number}/api/json")
      json_results['result'] == "SUCCESS"
    rescue NoMethodError => e
      puts "WARNING: #{e}".yellow
    end

    def revision_passed?()
      builds_list = get_builds()
      return false if builds_list.nil?
      
      builds_list.each do |build_number|
         if build_has_revision?(build_number) # check if build has the revision we care about
           return build_passed?(build_number)
         end
      end
      false
    end
    
    def self.load_into(configuration)
      configuration.load do
        namespace :jenkins_cap do
           desc "Check if this deployment as a good Jenkins build"
           task "build_check" do
             abort "\n\n\nThis revision #{real_revision} has not been built by Jenkins successfully!\n\n\n".red unless jenkins.revision_passed?
             puts "\n Revision #{real_revision} has passed Jenkins tests.\n".green
           end # end of task
        end # end of namespace
      end # end of configuration.load
    end # end of def self.load_into
    
  end # end of JenkinsCap module

  Capistrano.plugin :jenkins, JenkinsCap

end # end of Capistrano module

if Capistrano::Configuration.instance
  Capistrano::JenkinsCap.load_into(Capistrano::Configuration.instance)
end
