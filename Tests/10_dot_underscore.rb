=begin

Tim Kientzle suggested splitting the ascii test into a separate test, since this is related to an Apple convention for using "._" as a special file prefix.

=end

def is_installed
  true
end

def create
  `touch "._"`
end

def verify(original_dir)
  errors = %w(A B)
  errors.delete('A') if FileTest.exist?('._')
  Dir.chdir(original_dir) do
    errors.delete('B') if FileTest.exist?('._')
  end
  { :errors => errors }
end

