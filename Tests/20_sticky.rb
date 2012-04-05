=begin

=end
def is_installed
  true
end

def create
  `mkdir a_sticky_dir`
  `chmod +t a_sticky_dir`
  `touch a_sticky_file`
  `chmod +t a_sticky_file`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("a_sticky_dir")
    errors.delete('X')
    errors.delete('A') if File.stat("a_sticky_dir").sticky?
  end
  if FileTest.exist?("a_sticky_file")
    errors.delete('Y')
    errors.delete('B') if File.stat("a_sticky_file").sticky?
  end
  { :errors => errors }
end
