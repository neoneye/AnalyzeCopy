def is_installed
  true
end

def version
  "4.0.2"
end

def print_full_version
  puts "4.0.2"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using Panic's Transmit file manager" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
