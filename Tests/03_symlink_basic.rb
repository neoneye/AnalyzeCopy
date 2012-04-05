=begin


=end
def is_installed
  true
end

def create
  `touch file1`
  `ln -s file1 sl1`
  `ln -s sl1 sl2`

  `mkdir dir1`
  `ln -s dir1 sl3`
  `ln -s sl3 sl4`

end

def verify(original_dir)
  errors = %w(X Y A B C D)
  if FileTest.exist?("file1") && FileTest.exist?("sl1") && FileTest.exist?("sl2")
    errors.delete('X')
    errors.delete('A') if `readlink sl1` =~ /file1/
    errors.delete('B') if `readlink sl2` =~ /sl1/
  end

  if FileTest.exist?("dir1") && FileTest.exist?("sl3") && FileTest.exist?("sl4")
    errors.delete('Y')
    errors.delete('C') if `readlink sl3` =~ /dir1/
    errors.delete('D') if `readlink sl4` =~ /sl3/
  end
  { :errors => errors }
end
