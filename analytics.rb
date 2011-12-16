#!/usr/bin/env ruby

require 'uri'
require 'yaml'
require 'logger'
require 'rubygems'
require 'active_record'

dir = File.dirname(__FILE__)
load dir + '/models.rb'
load dir + '/config.rb'
load dir + '/email.rb'
load dir + '/git.rb'
load dir + '/db.rb'
load dir + '/schema.rb'
load dir + '/gcsv.rb'

def process_project(data)
  dir, range = data[:dir], data[:range]
  $l.info "total: %d" % (n = GitAnalytics::Git.count(dir, range))
  pdata = {:server      => data[:server],
           :origin      => data[:origin],
           :project     => data[:name],
           :description => data[:description]}
  GitAnalytics::DB.store_project(pdata)
  GitAnalytics::Git.log(dir, range, pdata) do |log|
    n = step_log(n, 1000, 'commits: ')
#    GitAnalytics::CSV.store(log)
    GitAnalytics::DB.store(log)
  end
end

def process
  each_server_config "Processing " do |server, config, projects|
#    GitAnalytics::CSV.open(config[:data][:csv])
    n = projects.size
    projects.each do |project, data|
      n = step_log(n, 1, '', " - #{project}")
      process_project(data)
    end
  end
end

def prepare
#  GitAnalytics::CSV.prepare($config[:cctlds], $config[:gtlds])
  GitAnalytics::Schema.create_tables
  GitAnalytics::Schema.add_indexes
#  GitAnalytics::Schema.remove_indexes
end

$l.info "Start"
prepare
process
$l.info "Finish"