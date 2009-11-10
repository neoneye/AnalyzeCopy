PATH = File.join(Dir.pwd, "utils", "ac_xattr")

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} -v`
end

def create
  `touch myfile`
  `#{PATH} -w com.opcoders.key1 "value1" myfile`
  `ln -s myfile mylink`
  `#{PATH} -s -w com.opcoders.key2 "value2" mylink`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("myfile")
    errors.delete('Y')
    s = `#{PATH} -l myfile`
    if s =~ /com.opcoders.key1.*value1/m
      errors.delete('B')
    end
  end
  if FileTest.exist?("mylink")
    errors.delete('X')
    s = `#{PATH} -sl mylink`
    if s =~ /com.opcoders.key2.*value2/m
      errors.delete('A')
    end
  end
  { :errors => errors }
end
