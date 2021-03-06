PATH = "/usr/bin/ditto"

def name
  'ditto'
end

def is_installed
  File.exists?(PATH)
end

def version
  'Part of ' + obtain_system_version
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
sudo #{PATH} --rsrc "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
