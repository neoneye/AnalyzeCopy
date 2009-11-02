PATH_CPIO = "/usr/bin/cpio"
PATH_FIND = "/usr/bin/find"

def is_installed
  File.exists?(PATH_CPIO) && File.exists?(PATH_FIND)
end

def version
  "versionless"
end

def print_full_version
  puts "versionless"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
cd "$SOURCE_DIR"
sudo #{PATH_FIND} . | sudo #{PATH_CPIO} -pdumv "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
