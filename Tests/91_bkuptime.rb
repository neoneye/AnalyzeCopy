PATH = File.join(Dir.pwd, "utils", "ac_bkuptime")

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} -v`
end

def create
  `touch myfile`
  `#{PATH} -w 1999_12_24_01_01_01 myfile`
end

def verify(original_dir)
  errors = %w(X A)
  if FileTest.exist?("myfile")
    errors.delete('X')
    s = `#{PATH} -r myfile`
    if s =~ /1999_12_24_01_01_01/m
      errors.delete('A')
    end
  end
  { :errors => errors }
end
