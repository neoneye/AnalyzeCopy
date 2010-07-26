def is_installed
  true
end

def create
  # HFS can do dates before epoch
  `touch before_epoch1`
  `touch before_epoch2`
  `SetFile -d 01/01/1904 before_epoch1`
  `SetFile -m 01/01/1905 before_epoch2`

  # A 32-bit Epoch date, wraps around in year 2038, so testing with dates 
  # after year 2038 will expose any Y2038 problems.
  `touch after_epoch1`
  `touch after_epoch2`
  `SetFile -d 01/01/2040 after_epoch1`
  `SetFile -m 01/01/2041 after_epoch2`
end

def verify(original_dir)
  errors = %w(X Y Z W A B C D)
  if FileTest.exist?("before_epoch1")
    errors.delete('X')
    s1 = `GetFileInfo -d before_epoch1`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -d before_epoch1`
    end
    if s1 == s2
      errors.delete('A')
    end
  end
  if FileTest.exist?("after_epoch1")
    errors.delete('Y')
    s1 = `GetFileInfo -d after_epoch1`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -d after_epoch1`
    end
    if s1 == s2
      errors.delete('B')
    end
  end
  if FileTest.exist?("before_epoch2")
    errors.delete('Z')
    s1 = `GetFileInfo -m before_epoch2`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -m before_epoch2`
    end
    if s1 == s2
      errors.delete('C')
    end
  end
  if FileTest.exist?("after_epoch2")
    errors.delete('W')
    s1 = `GetFileInfo -m after_epoch2`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -m after_epoch2`
    end
    if s1 == s2
      errors.delete('D')
    end
  end
  { :errors => errors }
end
