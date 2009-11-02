=begin
A broken symlink that doesn't point to an existing file

=end
def is_installed
  true
end

def version
  nil
end

def create
  `ln -s nonexisting sl1`
end

def verify(original_dir)
  errors = %w(X A)
  if File.lstat("sl1").symlink?
    errors.delete('X')
    errors.delete('A') if `readlink sl1` =~ /nonexisting/
  end
  { :errors => errors }
end
