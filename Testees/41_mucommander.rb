def name
  'muCommander'
end

def is_installed
  true
end

def version
  "0.8.5"
end

def print_full_version
  puts "0.8.5"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using muCommander" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
