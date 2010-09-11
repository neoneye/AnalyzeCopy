=begin
Uses "mkalias" and "hfsdata" by Sveinbjorn Thordarson
http://osxutils.sourceforge.net/
=end
PATH_MKALIAS = "/usr/local/bin/mkalias"
PATH_HFSDATA = "/usr/local/bin/hfsdata"

def is_installed
  File.exists?(PATH_MKALIAS) && File.exists?(PATH_HFSDATA)
end

def version
  `#{PATH_MKALIAS} -v`.sub(/version /, '').sub(/\s?by.*$/, '') + "\n"
  `#{PATH_HFSDATA} -v`.sub(/version /, '').sub(/\s?by.*$/, '') + "\n"
end

def create
  `touch my_orig_file`
  `#{PATH_MKALIAS} my_orig_file my_alias_file`

  `mkdir my_orig_dir`
  `#{PATH_MKALIAS} my_orig_dir my_alias_dir`
end

def verify(original_dir)
  errors = %w(X Y Z W A B)
  if FileTest.exist?("my_orig_file")
    errors.delete('X')
  end
  if FileTest.exist?("my_alias_file")
    errors.delete('Y')
    s = `#{PATH_HFSDATA} -e my_alias_file`
    errors.delete('A') if s =~ /my_orig_file/
  end
  if FileTest.exist?("my_orig_dir")
    errors.delete('Z')
  end
  if FileTest.exist?("my_alias_dir")
    errors.delete('W')
    s = `#{PATH_HFSDATA} -e my_alias_dir`
    errors.delete('B') if s =~ /my_orig_dir/
  end
  { :errors => errors }
end
