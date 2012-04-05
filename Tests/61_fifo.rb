def is_installed
  true
end

def create
  `mkfifo my_fifo_node`
end

def verify(original_dir)
  errors = %w(A B)
  if FileTest.exist?("my_fifo_node")
    errors.delete('B')
    if File.stat("my_fifo_node").ftype == "fifo"
      errors.delete('A')
    end
  end
  { :errors => errors }
end
