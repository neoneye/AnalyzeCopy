PATH = "/opt/local/bin/mc"

def name
  'Midnight Commander'
end

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} --version`.entries[0].strip
end

def print_full_version
  puts "todo"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using GNU Midnight Commander" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
