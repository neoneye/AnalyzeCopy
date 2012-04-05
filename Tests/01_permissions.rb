=begin

=end
def is_installed
  true
end

def create
  `touch file777`
  `sudo chmod 777 file777`

  `touch file400`
  `sudo chmod 400 file400`

  `touch file000`
  `sudo chmod 000 file000`
end

def verify(original_dir)
  errors = %w(X A Y B Z C)
  if FileTest.exist?("file777")
    errors.delete('X')
    errors.delete('A') if File.stat("file777").mode.to_s(8) == "100777"
  end
  if FileTest.exist?("file400")
    errors.delete('Y')
    errors.delete('B') if File.stat("file400").mode.to_s(8) == "100400"
  end
  if FileTest.exist?("file000")
    errors.delete('Z')
    errors.delete('C') if File.stat("file000").mode.to_s(8) == "100000"
  end
  { :errors => errors }
end
