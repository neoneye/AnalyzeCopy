PATH = "/usr/bin/rsync"

#
# on Mac OS X 10.6.3 rsync have started to hang forever in various tests, so I have
# disabled them in order for AnalyzeCopy to complete.
#
# oddly enough, on Mac OS X 10.5.8 there was no hangs.
#
def ignore_tests
  %w(50_hardlink_file 90_hardlink_dir 81_hardlink_fifo 41_symlink_hidden 61_fifo 52_char 53_block 60_alias 11_comment)
end

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} --version`.split("\n")[0].gsub(/version\s/i, '').sub(/protocol/i, '').strip
end

def print_full_version
  system "#{PATH} --version"
end

def copy_data(source_dir, dest_dir)
  # -v   verbose
  # -a   archive mode
  # -E   copy extended attributes, resource forks
  # -H   preserve hard links
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
sudo #{PATH} -vaEH "$SOURCE_DIR"/ "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
