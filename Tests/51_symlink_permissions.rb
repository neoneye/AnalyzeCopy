def is_installed
  true
end

def version
  nil
end

def create
  `touch file777`
  `sudo chmod 777 file777`
  `ln -s file777 link400`
  `sudo chmod -h 400 link400`
end

def verify(original_dir)
  errors = %w(X A Y B)
  if FileTest.exist?("file777")
    errors.delete('X')
    errors.delete('A') if File.stat("file777").mode.to_s(8) == "100777"
  end
  if FileTest.exist?("link400")
    errors.delete('Y')
    errors.delete('B') if File.lstat("link400").mode.to_s(8) == "120400"
  end
  { :errors => errors }
end
