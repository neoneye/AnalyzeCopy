def ignore_tests
  %w(20_timestamps 30_hidden 60_hardlink_file)
end

def is_installed
  true
end

def version
  "versionless"
end

def print_full_version
  puts "versionless"
end

def copy_data(source_dir, dest_dir)
  puts "not implemented"
  exit 1
end
