=begin
Uses "setfcomment" and "getfcomment" by Sveinbjorn Thordarson
http://osxutils.sourceforge.net/
=end
PATH_SETFCOMMENT = "/usr/local/bin/setfcomment"
PATH_GETFCOMMENT = "/usr/local/bin/getfcomment"

def is_installed
  File.exists?(PATH_SETFCOMMENT) && File.exists?(PATH_GETFCOMMENT)
end

def version
  `#{PATH_SETFCOMMENT} -v`.sub(/version /, '').sub(/\s?by.*$/, '') + "\n"
  `#{PATH_GETFCOMMENT} -v`.sub(/version /, '').sub(/\s?by.*$/, '') + "\n"
end

def create
  `touch my_file`
  `#{PATH_SETFCOMMENT} -c "hello file world" my_file`

  `mkdir my_dir`
  `#{PATH_SETFCOMMENT} -c "hello dir world" my_dir`
end

def verify(original_dir)
  puts `whoami`
  
  errors = %w(X Y A B)
  if FileTest.exist?("my_file")
    errors.delete('X')
    s = `#{PATH_GETFCOMMENT} my_file`
    puts "file comment is: #{s.inspect}" 
    errors.delete('A') if s =~ /hello file world/
  end
  if FileTest.exist?("my_dir")
    errors.delete('Y')
    s = `#{PATH_GETFCOMMENT} my_dir`
    puts "dir comment is: #{s.inspect}" 
    errors.delete('B') if s =~ /hello dir world/
  end
  { :errors => errors }
end
