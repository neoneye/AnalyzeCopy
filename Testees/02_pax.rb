PATH = "/bin/pax"

def name
  'pax'
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
mkdir "$DEST_DIR"
cd "$SOURCE_DIR"
sudo #{PATH} -rw -p e . "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
