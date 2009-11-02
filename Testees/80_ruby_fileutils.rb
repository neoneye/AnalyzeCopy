PATH = "/usr/bin/ruby"

def ignore_tests
  %w(10_permissions 12_ownership 14_uchg 15_access_control_list 71_symlink_cycle 80_fifo 81_char 82_block)
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
