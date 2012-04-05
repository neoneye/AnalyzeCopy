# GNU tar
PATH = "/usr/bin/gnutar"

def name
  'GNU tar'
end

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} --version`.split("\n").grep(/GNU tar/)[0].strip
end

def print_full_version
  system "#{PATH} --version"
end

def copy_data(source_dir, dest_dir)
  # copy using a tar-pipe
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$SOURCE_DIR"
sudo #{PATH} cvpf - . | (cd "$DEST_DIR"; sudo #{PATH} xvpf -)
CMD
  puts s
  puts "------------"
  system s
end
