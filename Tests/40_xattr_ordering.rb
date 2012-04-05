PATH = "/usr/bin/xattr"

def is_installed
  File.exists?(PATH)
end

def create
  `touch myfile`
  `#{PATH} -w com.opcoders.a_first "first" myfile`
  `#{PATH} -w com.opcoders.b_second "second" myfile`
  `#{PATH} -w com.opcoders.c_empty "" myfile`
  `#{PATH} -w com.opcoders.d_last "last" myfile`

  `mkdir mydir`
  `#{PATH} -w com.opcoders.a_first "first" mydir`
  `#{PATH} -w com.opcoders.b_second "second" mydir`
  `#{PATH} -w com.opcoders.c_empty "" mydir`
  `#{PATH} -w com.opcoders.d_last "last" mydir`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("myfile")
    errors.delete('X')
    s = `#{PATH} myfile`
    # see if ordering is preserved
    if s =~ /a_first.*b_second.*c_empty.*d_last/m
      errors.delete('A')
    end
  end
  if FileTest.exist?("mydir")
    errors.delete('Y')
    s = `#{PATH} mydir`
    # see if ordering is preserved
    if s =~ /a_first.*b_second.*c_empty.*d_last/m
      errors.delete('B')
    end
  end
  { :errors => errors }
end
