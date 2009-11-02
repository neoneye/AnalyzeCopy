#
# runner.rb - Run all the tests
# copyright 2009 - Simon Strandgaard
#
#
require "singleton"
require "yaml"
require "TesteeBase"
require "TestBase"

module RunnerMisc
  # load files as anonymous objects inherited from superklass
  def load_objects(filenames, superklass)
    filenames.map do |filename|
      path = File.expand_path(filename)
      v = Class.new(superklass)
      v.const_set('FILENAME', path)    
      v.const_set('NAME', File.basename(path, ".rb"))
      v.module_eval(IO.read(path), path)
      v.new
    end
  end

  def fork_output(filename, &block)
    fork do
      f = File.new(filename, "w+")
      $stdout.reopen f
      $stderr.reopen f
      begin
        block.call
      rescue => detail
        puts "============== EXCEPTION OCCURED =============="   
        puts "class:"   
        puts detail.class
        puts
        puts "message:"
        puts detail.message
        puts
        puts "backtrace:"
        puts detail.backtrace.join("\n")
        exit 1
      end
    end
    Process.wait
    $?.exitstatus
  end

end # module RunnerMisc


class Runner
  include Singleton
  include RunnerMisc
  
  def initialize
    @testees = load_objects(Dir["Testees/*.rb"], TesteeBase)
    @tests   = load_objects(Dir["Tests/*.rb"], TestBase)
    @testee_names = @testees.map {|t| t.class::NAME }
    @test_names = @tests.map {|t| t.class::NAME }
    @testees_installed = @testees.map {|t| t.is_installed }
    @tests_installed = @tests.map {|t| t.is_installed }
    # p self
    
#    @groups_and_tests = [["group0", nil], ["group1", %w(10_symlink 20_acl)]]
#    @testee_groups = ["group0", "group0", "group3", "group1"]
    @groups_and_tests = []
    @testee_groups = []
    assign_test_groups
  end
  
  attr_reader :testees, :tests
  attr_reader :testee_names, :test_names
  attr_reader :testees_installed, :tests_installed
  attr_reader :groups_and_tests, :testee_groups
  
  def inspect
    s = <<STR
testees: #{testee_names.inspect}
tests: #{test_names.inspect}
STR
    s.strip
  end 

  # When a testee chokes on a certain test
  # we can choose to ignore that test entirely!
  # This means that we may potentially have
  # one unique src_dir for every dest_dir.
  # However often its the same tests that causes
  # trouble, so only a few src_dirs will do.
  #
  # This function determines what src_dirs that
  # are necessary.
  def assign_test_groups
    dict = {
      nil => [-1]
    }
    @testees.each_with_index do |t, i|
      ary = t.ignore_tests
      (dict[ary] ||= []) << i
    end
    groups = dict.map {|k, v| [v, k]}.sort
#    p groups
    ary1 = []
    index2group = {}
    groups.each_with_index do |(indexes, testnames), group_index|
      group_name = "group%i" % group_index
      s = "ALL"
      if testnames && testnames.size > 0
        s = "excludes " + testnames.join(", ")
      end
#      puts "#{group_name} ... #{s}"
      indexes.each do |index|
        index2group[index] = group_name
      end
      ary1 << [group_name, testnames]
    end
#    p res
    ary2 = []
    @testees.each_with_index do |t, i|
      testee_name = testee_names[i]
      group_name = index2group[i]
#      puts "%30s ... %s" % [testee_name, group_name]
      ary2 << group_name
    end

    @groups_and_tests = ary1
    @testee_groups = ary2
#    puts "groups_and_tests: " + ary1.inspect
#    puts "   testee_groups: " + ary2.inspect
  end
  
  def check(dir)
    path = File.join(dir, "AnalyzeCopy-Volume")
    return if File.exists?(path)
    raise "ERROR: #{dir.inspect} is not a test volume, aborting!"
  end
  
  def clean(dir)
    # puts "cleaning: #{dir.inspect}"
    check(dir)
    @tests.each do |test|
      dir2 = File.join(dir, test.class::NAME)
      if FileTest.exist?(dir2)
        # puts "clean: #{dir2}"
        Dir.chdir(dir2) { test.clean }
        
        # some dirs requires root.. eg dirs made with "pax"
        ENV["RM_DIR"] = dir2
        `sudo rm -rf "$RM_DIR"`
#        FileUtils.rm_rf(dir2)
      end
      raise if FileTest.exist?(dir2)
    end
    # puts "cleaned successfully"
  end
  
  def clean_results(dir)
    @testees.each do |testee|
      dir1 = File.join(dir, testee.class::NAME)
      dir2 = File.join(dir, testee.class::NAME, "result")
      print "%-12s %22s ... " % ["Clean", testee.class::NAME]
      STDOUT.flush
      if FileTest.exist?(dir1)
        check(dir1)

        if FileTest.exist?(dir2)
          clean(dir2)
        end

        # some dirs requires root.. eg dirs made with "pax"
        ENV["RM_DIR"] = dir1
        `sudo rm -rf "$RM_DIR"`
#        FileUtils.rm_rf(dir1)
        # puts "remove: #{dir1}"
      end
      raise if FileTest.exist?(dir1)
      puts "ok"
    end
  end

  def create(dir)
    # puts "creating: #{dir.inspect}"
    check(dir)
    @groups_and_tests.each do |groupname, testnames|
      puts "------- #{groupname} -------"
      dir2 = File.join(dir, groupname)
      if FileTest.exist?(dir2)
        check(dir2)
        clean(dir2)
        FileUtils.rm_rf(dir2)
      end
      FileUtils.mkdir(dir2)
      FileUtils.touch(File.join(dir2, "AnalyzeCopy-Volume"))
      @tests.each_with_index do |test, index| 
        print "%-12s %22s ... " % ["Create", test.class::NAME]
        unless @tests_installed[index]
          puts "SKIPPED"
          next
        end
        if testnames && testnames.member?(test.class::NAME)
          puts "IGNORE"
          next
        end
        dir3 = File.join(dir2, test.class::NAME)
        FileUtils.mkdir(dir3)
        Dir.chdir(dir3) { test.create }
        puts "ok"
      end
    end
    # puts "created successfully"
  end

  def perform_copy(src_dir, dest_dir)
    check(src_dir)
    check(dest_dir)

    @testees.each_with_index do |testee, index|
      print "%-12s %22s ... " % ["Copy", testee.class::NAME]

      dir = File.join(dest_dir, testee.class::NAME)
      FileUtils.mkdir(dir)
      FileUtils.touch(File.join(dir, "AnalyzeCopy-Volume"))

      unless @testees_installed[index]
        puts "SKIPPED"
        FileUtils.touch(File.join(dir, "skipped"))
        next
      end
      
      groupname = @testee_groups[index]

      from_dir = File.join(src_dir, groupname)
      unless FileTest.exist?(from_dir)
        puts "SRCDIR NOT FOUND #{from_dir}"
        next
      end
      to_dir = File.join(dir, "result")
      Dir.chdir(dir) do
        fork_output("version.brief.txt") do
          puts testee.version
        end
        fork_output("version.full.txt") do
          testee.print_full_version
        end
        exitstatus = fork_output("log.copy.txt") do
          puts Time.now
          puts "------------"
          testee.copy_data(from_dir, to_dir)
        end
        File.open("exitstatus.txt", "w+") do |f|
          f.write exitstatus
        end

        if exitstatus == 0
          puts "ok"
        else
          puts "FAILED"
        end
      end

      volfile = File.join(to_dir, "AnalyzeCopy-Volume")
      unless FileTest.exist?(volfile)
        if FileTest.exist?(to_dir)
          begin
            FileUtils.touch(volfile)
          rescue => e
            puts "failed to touch file: #{e.inspect}"
          end
        end
      end

    end
  end

  def perform_verify(src_dir, dest_dir)
    check(src_dir)
    check(dest_dir)

    @testees.each_with_index do |testee, testee_index|
      print "%-12s %22s ... " % ["Verify", testee.class::NAME]

      unless @testees_installed[testee_index]
        puts "SKIPPED"
        next
      end

      groupname = @testee_groups[testee_index]

      from_dir = File.join(src_dir, groupname)
      unless FileTest.exist?(from_dir)
        puts "SRCDIR NOT FOUND #{from_dir}"
        next
      end

      testee_dir = File.join(dest_dir, testee.class::NAME)
      testee_result_dir = File.join(dest_dir, testee.class::NAME, "result")
      log_file = File.join(dest_dir, testee.class::NAME, "log.verify.txt")
      unless FileTest.exist?(testee_result_dir)
        puts "FAIL"
        next
      end

      name = testee.class::NAME
      pretty_name = name.sub(/^\d+_/, '')

      File.open(log_file, "w+") { |f| f.puts Time.now }

      results = {}
      @tests.each_with_index do |test, test_index|
        next unless @tests_installed[test_index]

        orig_dir = File.join(from_dir, test.class::NAME)
        result_dir = File.join(dest_dir, testee.class::NAME, "result", test.class::NAME)
        next unless FileTest.exist?(result_dir)

        testname = test.class::NAME

        Dir.chdir(result_dir) do
          rd, wr = IO.pipe
          fork do
            rd.close
            f = File.open(log_file, "a+")
            $stdout.reopen f
            $stderr.reopen f
            puts "==== #{testname} ===="
            dict = test.verify(orig_dir)
            wr.write YAML.dump(dict)
            wr.close
          end
          wr.close
          Process.wait
          result = YAML.load(rd.read)
          rd.close
          results[test.class::NAME] = result
        end

      end
      File.open(File.join(testee_dir, "results.yaml"), "w+") do |f|
        f.write YAML.dump(results)
      end
      puts "ok"
    end
  end

end # class Runner
