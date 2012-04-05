=begin

=end
def is_installed
  true
end

def create
  `touch my_setuid_file`
  `sudo chmod u+s my_setuid_file`

  `touch my_setgid_file`
  `sudo chmod g+s my_setgid_file`

  `touch my_set_gid_and_uid_file`
  `sudo chmod gu+s my_set_gid_and_uid_file`
end

def verify(original_dir)
  errors = %w(X Y Z A B C D)
  if FileTest.exist?("my_setuid_file")
    errors.delete('X')
    if File.stat("my_setuid_file").setuid?
      errors.delete('A')
    end
  end
  if FileTest.exist?("my_setgid_file")
    errors.delete('Y')
    if File.stat("my_setgid_file").setgid?
      errors.delete('B')
    end
  end
  if FileTest.exist?("my_set_gid_and_uid_file")
    errors.delete('Z')
    if File.stat("my_set_gid_and_uid_file").setgid?
      errors.delete('C')
    end
    if File.stat("my_set_gid_and_uid_file").setuid?
      errors.delete('D')
    end
  end
  { :errors => errors }
end
