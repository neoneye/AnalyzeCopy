PATH = "/usr/bin/xar"

def is_installed
  File.exists?(PATH)
end

def ignore_tests
  %w(01_ascii_names)
end

def version
  `#{PATH} --version`.strip
end

def print_full_version
  system "#{PATH} --version"
end

def copy_data(source_dir, dest_dir)
  ENV["TMP_FILE"] = File.join(dest_dir, "..", "tmpfile.xar")
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
touch "$TMP_FILE"
cd "$SOURCE_DIR"
sudo #{PATH} -cf "$TMP_FILE" .
cd "$DEST_DIR"
sudo #{PATH} -xf "$TMP_FILE"
CMD
  puts s
  puts "------------"
  system s
end
