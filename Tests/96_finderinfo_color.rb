=begin
Uses "mkalias" and "hfsdata" by Sveinbjorn Thordarson
http://osxutils.sourceforge.net/
=end
PATH_SETLABEL = "/usr/local/bin/setlabel"
PATH_HFSDATA = "/usr/local/bin/hfsdata"

def is_installed
  File.exists?(PATH_SETLABEL) && File.exists?(PATH_HFSDATA)
end

def version
  s0 = `#{PATH_SETLABEL} -v`.sub(/version /, '').sub(/\s?by.*\z/m, '')
  s1 = `#{PATH_HFSDATA} -v`.sub(/version /, '').sub(/\s?by.*\z/m, '')
  s0 + ' - ' + s1
end

def create
  FileUtils.touch("myfile")
  `#{PATH_SETLABEL} Red myfile`

  `mkdir mydir`
  `#{PATH_SETLABEL} Blue mydir`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("myfile")
    errors.delete('X')
    errors.delete('A') if `#{PATH_HFSDATA} -L myfile` =~ /^red$/i
  end
  if FileTest.exist?("mydir")
    errors.delete('Y')
    errors.delete('B') if `#{PATH_HFSDATA} -L mydir` =~ /^blue$/i
  end
  { :errors => errors }
end
