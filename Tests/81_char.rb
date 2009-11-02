def is_installed
  true
end

def version
  nil
end

def create
  `sudo mknod my_null_char_node c 3 2`
end

def verify(original_dir)
  errors = %w(A B)
  if FileTest.exist?("my_null_char_node")
    errors.delete('A')
    if File.stat("my_null_char_node").ftype == "characterSpecial"
      errors.delete('B')
    end
  end
  { :errors => errors }
end
