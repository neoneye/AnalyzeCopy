def is_installed
  true
end

def version
  nil
end

def create
  `touch my_locked_file`
  `chflags uchg my_locked_file`
end

def verify(original_dir)
  errors = %w(X A)
  if FileTest.exist?("my_locked_file")
    errors.delete('X')
    s1 = `stat -f '%f' my_locked_file`
    s2 = ""
    Dir.chdir(original_dir) do
      s2 = `stat -f '%f' my_locked_file`
    end
    errors.delete('A') if s1 == s2
  end
  { :errors => errors }
end

def clean
  `sudo chflags 0 my_locked_file`
end
