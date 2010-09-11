PATH_SETFILE = "/usr/bin/SetFile"
PATH_GETFILEINFO = "/usr/bin/GetFileInfo"

def is_installed
  a = File.exists?(PATH_SETFILE)
  b = File.exists?(PATH_GETFILEINFO)
  a && b
end

def create
  FileUtils.touch("myfile")
  `#{PATH_SETFILE} -a C myfile`

  `mkdir mydir`
  `#{PATH_SETFILE} -a C mydir`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("myfile")
    errors.delete('X')
    errors.delete('A') if `#{PATH_GETFILEINFO} -ac myfile` =~ /^1$/
  end
  if FileTest.exist?("mydir")
    errors.delete('Y')
    errors.delete('B') if `#{PATH_GETFILEINFO} -ac mydir` =~ /^1$/
  end
  { :errors => errors }
end
