def is_installed
  true
end

def create
  `touch file1`
  `SetFile -m 01/01/1904 file1`
  `touch file2`
  `SetFile -d 01/01/1905 file2`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("file1")
    errors.delete('X')
    s1 = `GetFileInfo -m file1`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -m file1`
    end
    if s1 == s2
      errors.delete('A')
    end
  end
  if FileTest.exist?("file2")
    errors.delete('Y')
    s1 = `GetFileInfo -d file2`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -d file2`
    end
    if s1 == s2
      errors.delete('B')
    end
  end
  { :errors => errors }
end
