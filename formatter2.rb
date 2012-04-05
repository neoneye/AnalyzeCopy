#
# formatter2.rb - Generate a pretty HTML table from CSV test results
# copyright 2009 - Simon Strandgaard
#
#
require_relative "runner"
require "csv"

module FormatterMisc2

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
<script type="text/javascript" src="sorttable.js"></script>
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
  <table class="result sortable" id="anyid">
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

class Formatter2
  include FormatterMisc2
  include RunnerMisc
  
  def initialize
    @system_version = "Mac OS X Version ?"
    @result_table = "EMPTY"
    @status_table = "EMPTY"
    @testname_table = "EMPTY"
  end
  attr_accessor :system_version
  
  def run(ary_tests)
    
    csv_rows = []
    CSV.foreach("index.csv") do |row|
      csv_rows << row
    end
    #CSV.open('index.csv', 'r', ';') do |row|
    #  csv_rows << row
    #end
    
    csv_columns = csv_rows.transpose
    
    column_name = []
    column_version = nil
    column_score = nil
    columns_result = []
        
    csv_columns.each do |column|
      row0 = column[0]
      case 
      when row0 =~ /^NAME$/i
        column_name = column
      when row0 =~ /^VERSION$/i
        column_version = column
      when row0 =~ /^SCORE%$/i
        column_score = column
      else
        columns_result << column
      end
    end
    
   
    html_result_rows = []
    begin
      cells = []
      cells << th("PROGRAM")
      cells << th("SCORE")
      columns_result.each_with_index do |column, index|
        row0 = column[0]
        name = "COL#{index}"
        tooltip = "Column #{index}"
        match = row0.match(/^(\d+)_(.*)$/)
        if match
          name = match[1]
          tooltip = row0
        end
        html_attr = ' title="' + tooltip + '"'
        cells << th(name, html_attr)
      end
      html_result_rows << tr(cells.join)
    end

    
    column_name.each_index do |index|
      next if index == 0

      cells = []
      

      begin
        s1 = column_name[index]
        s2 = column_version[index]
        cells << td("<b>#{s1}</b><br/><pre>#{s2}</pre>", " class='testeeinfo'")
      end

      score = 0
      
      begin
        s1 = column_score[index]
        score = s1.to_i
        cells << td(s1, " class='score'")
      end

      columns_result.each do |column|
        s1 = column[index]
        if s1 =~ /^OK$/i
          sortkey = "%i%03i%03i" % [4, 0, score]
          cells << td('&nbsp;', " class='pass datacell' sorttable_customkey='#{sortkey}'")
        elsif s1 =~ /^FAIL (.*)$/i
          n = 99 - s1.size
          sortkey = "%i%03i%03i" % [3, n, score]
          cells << td($1, " class='fail datacell' sorttable_customkey='#{sortkey}'")
        elsif s1 =~ /^CODE (.*)$/i
          n = $1.to_i
          sortkey = "%i%03i%03i" % [2, n, score]
          cells << td($1, " class='other datacell' sorttable_customkey='#{sortkey}'")
        else
          sortkey = "%i%03i%03i" % [1, 0, score]
          cells << td('ERR', " class='other datacell' sorttable_customkey='#{sortkey}'")
        end
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
  
end # class Formatter2