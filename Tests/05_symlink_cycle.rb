=begin


=end
def is_installed
  true
end

def create
  # a cycle of three symlinks
  `ln -s sl3 sl1`
  `ln -s sl1 sl2`
  `ln -s sl2 sl3`
  
  # a symlink that points to itself
  `ln -s slx slx`
end

def verify(original_dir)
  errors = %w(X Y A B C D)
  if File.lstat("sl1").symlink? &&
      File.lstat("sl2").symlink? &&
      File.lstat("sl3").symlink?
    errors.delete('X')
    errors.delete('A') if `readlink sl1` =~ /sl3/
    errors.delete('B') if `readlink sl2` =~ /sl1/
    errors.delete('C') if `readlink sl3` =~ /sl2/
  end
  if File.lstat("slx").symlink?
    errors.delete('Y')
    errors.delete('D') if `readlink slx` =~ /slx/
  end
  { :errors => errors }
end
