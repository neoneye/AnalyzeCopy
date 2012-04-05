=begin

the man page for "cp" says:
Note that cp copies hard-linked files as separate files.  If you
need to preserve hard links, consider using tar(1), cpio(1), or
pax(1) instead.

=end
PATH = "/bin/cp"

def name
  'cp'
end

def is_installed
  File.exists?(PATH)
end

def version
  'Part of ' + obtain_system_version
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
sudo #{PATH} -Rp "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
