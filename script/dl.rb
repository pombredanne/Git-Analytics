#!/usr/bin/env ruby

require 'yaml'

$: << File.join(File.dirname(__FILE__), '.')
require 'config'

each_server_config("Downloading projects for ") do |server, config|
  n = $projects[server].size
  $projects[server].each do |path, project| n -= 1
    STDERR.printf "[%s] %5d - %s\n", Time.now.strftime("%H:%M:%S"), n, path
    name, dir, url = project[:name], project[:dir], project[:git]
    case
    when project[:fork]
      system "git --git-dir=#{dir} remote add #{name} #{url}"
    when !File.exists?(dir)
      system "mkdir -p #{dir}; git clone --mirror #{url} #{dir}"
    end
    # --prune removes project forks, should be avoided
    system "git --git-dir=#{dir} remote update"
  end
end

