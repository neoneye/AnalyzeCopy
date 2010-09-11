def is_installed
  true
end

def version
  nil
end

def create
  `touch myfile`
  `ln -s myfile mylink`
  `SetFile -P -a V mylink`
end

def verify(original_dir)
  errors = %w(X Y A)
  if FileTest.exist?("myfile")
    errors.delete('X')
  end
  if FileTest.exist?("mylink")
    errors.delete('Y')
    if `ls -lO mylink` =~ /hidden/
      errors.delete('A')
    end
  end
  { :errors => errors }
end
