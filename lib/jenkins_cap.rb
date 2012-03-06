require 'json'

Capistrano::Configuration.instance(true).load do

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
    end

    def get_revision_from_build(build_number)
      json_results = json_request("#{jenkins_host}/job/#{jenkins_job_name}/#{build_number}/api/json")
      return nil if json_results['changeSet']['revisions'].nil?
      revisions = [] 
      json_results['changeSet']['revisions'].each{|r| revisions << r['revision']}
      revisions.sort.last
    end

    def build_has_current_revision?(build_number)
      build_revision = get_revision_from_build(build_number)
      puts build_revision
      build_revision.to_i == current_revision.to_i
    end

    def build_passed?(build_number)
      json_results = json_request("#{jenkins_host}/job/#{jenkins_job_name}/#{build_number}/api/json")
      puts json_results['result']
      json_results['result'] == "SUCCESS"
    end

    def revision_passed?()
      builds_list = get_builds()
      builds_list.each do |build_number|
         puts "checking #{build_number}"
         if build_has_current_revision?(build_number) # check if build has the revision we care about
           return build_passed?(build_number)
         end
      end
      false
    end
  end

  Capistrano.plugin :jenkins, JenkinsCap

  namespace :jenkinscap do
     desc "Check if this deployment as a good Jenkins build"
     task "build_check" do
       if (not jenkins.revision_passed?)
          abort "\n\n\n\e[0;31m This revision #{current_revision} has not been built by Jenkins successfully!  \e[0m\n\n\n"
       end
     end
  end

end