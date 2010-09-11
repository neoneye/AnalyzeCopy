PATH_PYTHON = "/usr/bin/python"
PATH_COPY = File.join(Dir.pwd, "scripts", "ac_python_copy.py")

def ignore_tests
  %w(12_symlink_cycle 61_fifo 81_hardlink_fifo)
end

def is_installed
  File.exists?(PATH_PYTHON) && File.exists?(PATH_COPY)
end

def version
  s1 = `#{PATH_PYTHON} --version 2>&1`.strip
  s2 = `#{PATH_COPY}`.entries[0].strip
  "#{s1}\n#{s2}"
end

def print_full_version
  system "#{PATH_PYTHON} --version"
  puts "------------"
  system "#{PATH_COPY}"
end

def copy_data(source_dir, dest_dir)
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
sudo #{PATH_COPY} "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
