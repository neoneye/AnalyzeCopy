def is_installed
  true
end

def create
  `touch myfile`
  `ln -s myfile mylink`
  `SetFile -P -m 11/11/2011 mylink`
  `SetFile -m 01/01/2001 myfile`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("mylink")
    errors.delete('X')
    s1 = `GetFileInfo -P -m mylink`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -P -m mylink`
    end
    if s1 == s2
      errors.delete('A')
    end
  end
  if FileTest.exist?("myfile")
    errors.delete('Y')
    s1 = `GetFileInfo -m myfile`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -m myfile`
    end
    if s1 == s2
      errors.delete('B')
    end
  end
  { :errors => errors }
end
