=begin

Latest version of tar can be found here
http://code.google.com/p/libarchive/

Tim Kientzle: For portability reasons, tar does not archive "birthtime" attributes in the default format.  Adding --format=pax to the tar command line when creating the archive fixes this.

=end

# BSD tar
PATH = "/usr/bin/tar"

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} --version`.strip
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
sudo #{PATH} cvpf - --format=pax . | (cd "$DEST_DIR"; sudo #{PATH} xvpf -)
CMD
  puts s
  puts "------------"
  system s
end
