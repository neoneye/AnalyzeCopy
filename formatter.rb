#
# formatter.rb - Generate a pretty HTML table with test results
# copyright 2009 - Simon Strandgaard
#
#
require "runner"

module FormatterMisc

  def td(s, html_attr='')
    "<td#{html_attr}>#{s}</td>"
  end

  def th(s, html_attr='')
    "<th#{html_attr}>#{s}</th>"
  end

  def tr(s, html_attr='')
    "<tr#{html_attr}>#{s}</tr>"
  end

  HTML_TEMPLATE =<<HTMLDOC
<html>
<head>
<title>Analyze Copy</title>
<style type="text/css">
body {
	font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif;
	font-size: 12px;
	background-color: gray;
  background-color: #ccc;
}
td, th, pre {
	font-size: 12px;
}
pre {
  margin-top: 0px;
}
.resultwrap {
  padding: 5px 5px;
	background-color: gray;
  border: 1px solid #222;
}
table.result {
  border-collapse: collapse;
  background-color: #ccc;
}
table.result, table.result td, table.result th {
  border: 1px solid #222;
}
table.result td, table.result th {
  height: 30px;
}
td.legend {
  width: 40px;
  height: 30px;
  text-align: center;
}
td.fail {
  background-color: #f12;
}
td.pass {
  background-color: #0a2;
}
td.other {
  background-color: black;
  color: white;
}
td.score {
  font-size: 15px;
  font-weight: bold;
  text-align: right;
}
td.testeeinfo {
}
table.result td.datacell {
  width: 40px;
  text-align: center;
}
table.result tr {
}
table.result td, table.result th {
  padding: 0.25em;
}
div.leftside {
  float: left;
  display: inline;
}
div.rightside {
  float: left;
  display: inline;
  width: 30em;
}
table.testnametable {
}
table.statustable {
}
.inner {
  margin: 1em 1em;
}
</style>
</head>
<body>
<h1>Analyze Copy - Copyright 2009-2011 Simon Strandgaard &lt;simon@opcoders.com&gt;</h1>
<pre>INSERT_SYSVERSION</pre>

<div class="leftside"
  <div class="resultwrap">
  <table class="result">
  INSERT_RESULTTABLE
  </table>
  </div>
</div>

<div class="rightside"><div class="inner">
  <h2>Test List</h2>
  <table class="testnametable">
  INSERT_TESTNAMETABLE
  </table>

  <h2>Status List</h2>
  <table class="statustable">
  INSERT_STATUSTABLE
  </table>

  <h2>Color List</h2>
  <table class="colortable">
  <tr><td class="legend pass">&nbsp;</td><td>Passed this test.</td></tr>
  <tr><td class="legend fail">ABC</td><td>Failed in subtest A, B and C.</td></tr>
  <tr><td class="legend other">7</td><td>Status code is 7.</td></tr>
  </table>
</div></div>

</body></html>
HTMLDOC


end # module FormatterMisc

class Formatter
  include FormatterMisc
  include RunnerMisc
  
  def initialize
    @system_version = "Mac OS X Version ?"
    @result_table = "EMPTY"
    @status_table = "EMPTY"
    @testname_table = "EMPTY"
  end
  attr_accessor :system_version
  
  def run(dest_dir, ary_tests, ary_testees)

    html_result_rows = []
    begin
      cells = []
      cells << td("")
      ary_tests.each do |test|
        title = test[:prettyname].gsub(/[^A-Za-z0-9_]/, '')
        html_attr = ' title="' + title + '"'
        cells << th(test[:ident], html_attr)
      end
      cells << th("SCORE")
      html_result_rows << tr(cells.join)
    end

    ary_testees.each do |testee|
      cells = []

      is_testee_installed = testee[:is_installed]

      begin
        s1 = testee[:name]
        s2 = testee[:version]
        html_attr = " class='testeeinfo'"
        cells << td("<b>#{s1}</b><br/><pre>#{s2}</pre>", html_attr)
      end


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

        html_attr = " class='other datacell'"
        s = "ERROR"
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
#=begin
        when !testee_results[test_name].has_key?(:errors)
          s = STATUSES[:bad_data_for_this_test][:short]
        when !testee_results[test_name][:errors].kind_of?(Array)
          s = STATUSES[:bad_data_for_this_test][:short]
        when testee_results[test_name][:errors].size > 0
          errors = testee_results[test_name][:errors]
          s = errors.join()
          html_attr = " class='fail datacell'"
#=end
        else
          s = "&nbsp;"
          html_attr = " class='pass datacell'"
          n_pass += 1
        end

        cells << td(s, html_attr)
      end
      begin
        score = '0 %'
        if n >= 1
          score = (n_pass.to_f * 100.0 / n.to_f).to_i.to_s + '%'
        end
        cells << td(score, " class='score'")
      end
      html_result_rows << tr(cells.join)
    end
    @result_table = html_result_rows.join

    html_testname_rows = []
    ary_tests.each do |test|
      html_attr1 = " class='ident'"   
      html_attr2 = " class='value'"
      s = td(test[:ident], html_attr1) 
      s += td(test[:prettyname], html_attr2)
      html_testname_rows << tr(s)
    end
    @testname_table = html_testname_rows.join

    html_status_rows = []
    STATUSES.values.sort_by { |dict| dict[:short] }.each do |d|
      html_attr1 = " class='ident'"   
      html_attr2 = " class='value'"
      s = td(d[:short], html_attr1) + td(d[:desc], html_attr2)
      html_status_rows << tr(s)
    end
    @status_table = html_status_rows.join
  end

  def write(filename)
    doc = HTML_TEMPLATE.dup
    doc.gsub!('INSERT_SYSVERSION', @system_version)
    doc.gsub!('INSERT_RESULTTABLE', @result_table)
    doc.gsub!('INSERT_STATUSTABLE', @status_table)
    doc.gsub!('INSERT_TESTNAMETABLE', @testname_table)
    File.open(filename, "w+") {|f| f.write(doc) }
  end
  
end # class Formatter