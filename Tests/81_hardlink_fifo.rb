def is_installed
  true
end

def version
  nil
end

def create
  `mkfifo fifo1`
  `ln fifo1 fifo2`
end

def verify(original_dir)
  errors = %w(X Y A B C)
  if FileTest.exist?("fifo1")
    errors.delete('X')
    if FileTest.exist?("fifo2")
      errors.delete('Y')
      errors.delete('B') if File.stat("fifo1").ftype == "fifo"
      errors.delete('C') if File.stat("fifo2").ftype == "fifo"
      ino1 = File.stat("fifo1").ino
      ino2 = File.stat("fifo2").ino
      errors.delete('A') if ino1 == ino2
    end
  end
  { :errors => errors }
end
