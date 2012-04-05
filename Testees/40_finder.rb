def name
  'Finder'
end

def is_installed
  true
end

def version
  'Part of ' + obtain_system_version
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using Finder" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
