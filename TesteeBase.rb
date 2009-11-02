class TesteeBase
  FILENAME = nil
  NAME = nil
  
  # some tests are evil and makes bad programs choke
  # returns a string array with test names to be ignored
  # or returns nil in which case all tests will be run
  def ignore_tests
    nil
  end
  
  # determines if the testee program is installed
  def is_installed
    false
  end

  # obtain the program names + version numbers
  def version
    "sometool 6.6.6"
  end
  
  # invoke the programs and let them print their 
  # version info to stdout/stderr 
  def print_full_version
    puts version
  end
  
  # invoke the programs and let them do their job
  # while they print out verbose info to stdout/stderr
  def copy_data(source_dir, dest_dir)
    puts "#{source_dir.inspect}  ->  #{dest_dir.inspect}"
  end
end