PATH = "/usr/bin/rsync"

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} --version`.entries[0].gsub(/version\s/i, '').sub(/protocol/i, '').strip
end

def print_full_version
  system "#{PATH} --version"
end

def copy_data(source_dir, dest_dir)
  # -a   archive mode
  # -E   copy extended attributes, resource forks
  # -H   preserve hard links
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
sudo #{PATH} -aEH "$SOURCE_DIR"/ "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
