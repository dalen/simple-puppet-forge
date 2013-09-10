#!/usr/bin/env ruby

require 'sinatra/base'
require 'json'

class SimplePuppetForge < Sinatra::Base

  configure do
    set :module_dir, '/var/lib/simple-puppet-forge/modules'
    enable :logging
  end

  # API request for a module
  get '/api/v1/releases.json' do
    modules = {}
    unprocessed = [params[:module]]
    while mod = unprocessed.shift
      next if modules[mod] # This module has already been added

      user, modname = mod.split '/'
      release_list = list_modules(user, modname)
      if !release_list.empty?
        modules[mod] = release_list
        unprocessed += modules_dependencies(release_list)
      end
    end

    if modules.empty?
      status 410
      return { 'error' => "Module #{user}/#{modname} not found"}.to_json
    else
      modules.each_key do |m|
        modules[m] = modules[m].collect { |release| release.to_hash }
      end
      return modules.to_json
    end
  end

  # Serve the module itself
  get '*/modules/:user/:module/:file' do
    send_file File.join(settings.module_dir, params[:user], params[:module], params[:file])
  end

  # From a list of modules get a list of modules (names) they depend on
  def modules_dependencies(modules)
    modules.collect { |m| m.dependencies.collect { |d| d.first } }.flatten.uniq
  end

  # List modules matching user and module
  def list_modules(user, mod)
    require 'simple_puppet_forge/module'

    dir = File.join(settings.module_dir, user, mod)

    begin
      Dir.entries(dir).select do |e|
        e.match(/^#{Regexp.escape user}-#{Regexp.escape mod}-.*.tar\.gz$/)
      end.sort.reverse.collect do |f|
        path = File.join(dir, f)
        begin
          Module.new(path, settings.module_dir)
        rescue RuntimeError => e
          logger.error e.message
          nil
        end
      end.compact
    rescue Errno::ENOENT
      return []
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
