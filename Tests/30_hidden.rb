SETFILE_PATH = "/usr/bin/SetFile"
GETFILEINFO_PATH = "/usr/bin/GetFileInfo"
CHFLAGS_PATH = "/usr/bin/chflags"

def is_installed
  a = File.exists?(SETFILE_PATH)
  b = File.exists?(GETFILEINFO_PATH)
  c = File.exists?(CHFLAGS_PATH)
  a && b && c
end

def create
  FileUtils.touch(".dotfile.txt")
  
  FileUtils.touch("invisible.txt")
  `SetFile -a V invisible.txt`

  FileUtils.touch("hidden.txt")
  `chflags hidden hidden.txt`
end

def verify(original_dir)
  errors = %w(X Y Z A B)
  errors.delete('X') if FileTest.exist?(".dotfile.txt")
  if FileTest.exist?("invisible.txt")
    errors.delete('Y')
    errors.delete('A') if `GetFileInfo -av invisible.txt` =~ /^1$/
  end
  if FileTest.exist?("hidden.txt")
    errors.delete('Z')
    errors.delete('B') if `ls -lO` =~ /^.*hidden.*hidden.txt$/
  end
  { :errors => errors }
end
