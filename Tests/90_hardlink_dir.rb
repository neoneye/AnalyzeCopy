=begin


=end
PATH = File.join(Dir.pwd, "utils", "bb_hardlink")

def is_installed
  File.exists?(PATH)
end

def create
  `mkdir dir1`
  `mkdir dir1/subdir`
  `mkdir dir2`
  `#{PATH} dir1/subdir dir2/subdir`
  `touch dir1/subdir/file1`
end

def verify(original_dir)
  errors = %w(X Y A)
  if FileTest.exist?("dir1/subdir")
    errors.delete('X')
    if FileTest.exist?("dir2/subdir")
      errors.delete('Y')
      ino1 = File.stat("dir1/subdir").ino
      ino2 = File.stat("dir2/subdir").ino
      errors.delete('A') if ino1 == ino2
    end
  end
  { :errors => errors }
end
