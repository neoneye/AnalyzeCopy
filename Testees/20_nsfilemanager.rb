PATH = File.join(Dir.pwd, "utils", "ac_copy")

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH}`.entries[0].strip
end

def print_full_version
  system PATH
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
sudo #{PATH} "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
