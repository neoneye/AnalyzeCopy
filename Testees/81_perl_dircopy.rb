PATH_PERL = "/usr/bin/perl"
PATH_COPY = File.join(Dir.pwd, "scripts", "ac_perl_copy.pl")

def ignore_tests
  %w(61_fifo 81_hardlink_fifo)
end

def is_installed
  File.exists?(PATH_PERL) && File.exists?(PATH_COPY)
end

def version
  output = `#{PATH_COPY}`
  if output =~ /Recursive.pm/
    raise "install File::Copy::Recursive is not installed"
  end
  s1 = `#{PATH_PERL} --version`.strip.split("\n")[0]
  s1.sub!(/This is /i, '')
  s1.sub!(/, v/i, ' ')
  s1.sub!(/built for.*?$/i, '')
  s1.strip!
  s2 = output.split("\n")[0].strip
  "#{s1} - #{s2}"
end

def print_full_version
  system "#{PATH_PERL} --version"
  puts "------------"
  system "#{PATH_COPY}"
end

def copy_data(source_dir, dest_dir)
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
sudo #{PATH_COPY} "$SOURCE_DIR" "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end
