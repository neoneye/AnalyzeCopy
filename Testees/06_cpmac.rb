#
# If I use the -p option for preserving metadata then I get an error,
# so I don't use the -p option in this test.
#
# prompt> sudo CpMac -p -r group0 /Volumes/AnalyzeCopyDest/06_cpmac/result
# could not preserve the destination modification or creation date (-35)
#
# If anyone manage to get the -p option to work, let me know
#
PATH = "/usr/bin/CpMac"

def name
  'CpMac'
end

def is_installed
  File.exists?(PATH)
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
sudo #{PATH} -r "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
