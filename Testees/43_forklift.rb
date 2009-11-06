def ignore_tests
  %w(10_permissions)
end

def is_installed
  true
end

def version
  "1.5.3"
end

def print_full_version
  puts "1.5.3"
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
