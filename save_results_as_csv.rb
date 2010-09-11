#
# save_results_as_csv.rb - Generate a CSV file with test results
# copyright 2010 - Simon Strandgaard
#
#
require "csv"
require "runner"

class CSVResults
  include RunnerMisc
  
  def initialize
    @csv_result_rows = []
  end
  
  def run(dest_dir, ary_tests, ary_testees)

    csv_result_rows = []
    begin
      cells = []
      # name column             
      cells << "NAME"  
      # version column
      cells << "VERSION"  
      # multiple result columns
      ary_tests.each do |test|
        cells << test[:name]
      end
      # score column
      cells << "SCORE" 
      csv_result_rows << cells
    end

    ary_testees.each do |testee|
      cells = []

      is_testee_installed = testee[:is_installed]

      # name column             
      cells << testee[:name]

      # version column
      cells << testee[:version]


      testee_dir = File.join(dest_dir, testee[:name])
      testee_result_dir = File.join(dest_dir, testee[:name], "result")
      has_testee_result_dir = FileTest.exist?(testee_result_dir)

      testee_results_yaml = File.join(testee_dir, "results.yaml")
      testee_results = nil
      if FileTest.exist?(testee_results_yaml)
        testee_results = YAML.load(IO.read(testee_results_yaml))
        if !testee_results.kind_of?(Hash)
          testee_results = nil
        end
      end

      n = ary_tests.size
      n_pass = 0
      ary_tests.each do |test|
        is_test_installed = test[:is_installed]
        test_name = test[:name]

        test_dir = File.join(dest_dir, testee[:name], "result", test_name)
        has_test_dir = FileTest.exist?(test_dir)

        s = "OTHER"
        case 
        when !is_testee_installed || !is_test_installed
          s = STATUSES[:not_installed][:short]
        when !has_testee_result_dir
          s = STATUSES[:missing_testee_result_dir][:short]
        when !has_test_dir
          s = STATUSES[:missing_test_dir][:short]
        when !testee_results
          s = STATUSES[:missing_results_yaml][:short]
        when testee_results[test_name] == nil
          s = STATUSES[:no_data_for_this_test][:short]
        when testee_results[test_name] == false
          s = STATUSES[:no_data_for_this_test][:short]
=begin
        when !testee_results[test_name].has_key?(:mask)
          s = STATUSES[:bad_data_for_this_test][:short]
        when !testee_results[test_name][:mask].kind_of?(Fixnum)
          s = STATUSES[:bad_data_for_this_test][:short]
        when testee_results[test_name][:mask] > 0
          mask = testee_results[test_name][:mask]
          s = "<b>FAIL</b><br/>" + mask.to_s(2)
          html_attr = " class='fail datacell'"
=end
        when !testee_results[test_name].has_key?(:errors)
          s = STATUSES[:bad_data_for_this_test][:short]
        when !testee_results[test_name][:errors].kind_of?(Array)
          s = STATUSES[:bad_data_for_this_test][:short]
        when testee_results[test_name][:errors].size > 0
          errors = testee_results[test_name][:errors]
          s = "FAIL " + errors.join()
        else
          s = "PASS"
          n_pass += 1
        end

        cells << s
      end
      begin
        score = '0 %'
        if n >= 1
          score = (n_pass.to_f * 100.0 / n.to_f).to_i.to_s + '%'
        end
        cells << score
      end
      csv_result_rows << cells
    end
    @csv_result_rows = csv_result_rows
  end

  def write(filename)
    File.open(filename, "w+") do |f| 
      CSV::Writer.generate(f, ',') do |csv|
        @csv_result_rows.each do |row|
          csv << row
        end
      end
    end
  end
  
end # class CSVResults