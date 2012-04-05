=begin


=end
def is_installed
  true
end

def create
  `touch file1`
  `ln file1 file2`
  `ln file2 file3`
end

def verify(original_dir)
  errors = %w(X Y Z A B)
  if FileTest.exist?("file1")
    errors.delete('X')
    if FileTest.exist?("file2")
      errors.delete('Y')
      if FileTest.exist?("file3")
        errors.delete('Z')
        ino1 = File.stat("file1").ino
        ino2 = File.stat("file2").ino
        ino3 = File.stat("file3").ino
        errors.delete('A') if ino1 == ino2
        errors.delete('B') if ino1 == ino3
      end
    end
  end
  { :errors => errors }
end
