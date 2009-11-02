=begin
this test checks if stat.mtime is preserved during copy

=end
def is_installed
  true
end

def create
  `touch my_file.txt`
  `SetFile -m 12/31/1999 my_file.txt`                  
  `SetFile -d 01/01/2001 my_file.txt`
end

def verify(original_dir)
  errors = %w(X A)
  if FileTest.exist?("my_file.txt")
    errors.delete('X')
    s1 = `GetFileInfo -m my_file.txt`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -m my_file.txt`
    end
    errors.delete('A') if s1 == s2
  end
  { :errors => errors }
end
