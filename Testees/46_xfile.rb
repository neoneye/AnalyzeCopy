def ignore_tests
  %w(80_fifo 81_char 82_block)
end

def is_installed
  true
end

def version
  "1.8"
end

def print_full_version
  puts "1.8"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using Xfile" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
