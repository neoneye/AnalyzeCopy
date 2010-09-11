def ignore_tests
  %w(01_permissions)
end

def is_installed
  true
end

def version
  "2.0 Beta 1 (20)"
end

def print_full_version
  puts "2.0 Beta 1 (20)"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using ForkLift" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
