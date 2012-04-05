PATH = "/usr/bin/ruby"

def name
  'Ruby FileUtils.cp_r'
end

def ignore_tests
  %w(01_permissions 02_symlink_broken 03_symlink_basic 12_symlink_cycle 22_access_control_list 23_ownership 31_uchg 52_char 53_block 61_fifo 81_hardlink_fifo)
end

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} -v`.sub(/\s?patchlevel\s\d+/i, '').sub(/\[universa.*/i, '').strip
end

def print_full_version
  system "#{PATH} -v"
end

def copy_data(source_dir, dest_dir)
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  ENV["SCRIPT_CODE"] = "require 'fileutils'; FileUtils.cp_r( ENV['SOURCE_DIR'], ENV['DEST_DIR'], :preserve => true)"

  s = <<CMD
#{PATH} -e "$SCRIPT_CODE"
CMD
  puts s
  puts "------------"
  system s
end
