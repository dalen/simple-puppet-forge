require 'simple_puppet_forge'
require 'json'

class SimplePuppetForge::Module
  attr_reader :path, :uripath, :metadata

  def initialize(path, uri_root_path)
    @path = path
    @uripath = '/modules' + path[uri_root_path.chomp('/').length..-1].chomp('/')
    @metadata_path = path + '.metadata'

    extract_metadata
    read_metadata
  end

  # Extract the metdata if it doesn't exist or if the module has been updated
  def extract_metadata
    if File.exist?(@metadata_path)
      if File.stat(@metadata_path).mtime > File.stat(@path).mtime
        return
      end
    end
    # TODO: support others than GNU tar
    `tar -z -x -O --wildcards -f #{@path} '*/metadata.json' > #{@metadata_path}`
    raise "Failed to extract metadata for #{@path}" unless $?.success?
  end

  # Read the metadata file
  def read_metadata
    begin
      metadata_file = File.open(@metadata_path, 'r')
      @metadata = JSON.parse metadata_file.read
      metadata_file.close
      @metadata
    rescue
      raise "Failed to read metadata file #{@metadata_path}"
    end
  end

  def dependencies
    @metadata['dependencies'].collect do |dep|
      ret = [dep['name']]
      ret << dep['version_requirement'] if dep['version_requirement']
      ret
    end
  end

  def version
    @metadata['version']
  end

  def name
    @metadata['name']
  end

  def to_hash
    {
      'file'         => @uripath,
      'version'      => version,
      'dependencies' => dependencies,
    }
  end
end
