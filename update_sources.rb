require 'json'
require 'open-uri'
require 'digest'
require 'fileutils'

CONFIG_FILE = 'upstream_sources.json'

unless File.exist?(CONFIG_FILE)
  puts "No configuration file (#{CONFIG_FILE}) found. Skipping update check."
  exit 0
end

sources = JSON.parse(File.read(CONFIG_FILE))
any_updates = false

sources.each do |local_path, url|
  print "Checking #{local_path} ... "
  
  # Ensure the destination directory exists
  FileUtils.mkdir_p(File.dirname(local_path))

  begin
    # Download the remote file into memory (or temp file) to calculate hash
    remote_data = URI.open(url).read
    remote_hash = Digest::SHA256.hexdigest(remote_data)

    if File.exist?(local_path)
      local_data = File.read(local_path)
      local_hash = Digest::SHA256.hexdigest(local_data)
    else
      local_hash = nil
    end

    if local_hash != remote_hash
      puts "UPDATE FOUND"
      puts "   - Local SHA:  #{local_hash || 'Not found'}"
      puts "   - Remote SHA: #{remote_hash}"
      
      File.open(local_path, 'wb') { |f| f.write(remote_data) }
      any_updates = true
    else
      puts "Up to date."
    end
    
  rescue StandardError => e
    puts "ERROR"
    puts "   Failed to fetch #{url}: #{e.message}"
    # Exit with error so CI fails if a source URL is broken
    exit 1 
  end
end