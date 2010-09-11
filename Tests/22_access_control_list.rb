=begin

TODO: exercise invalid ACL's
TODO: exercise preservation of ACL order
TODO: exercise inherited property

=end

def is_installed
  true
end

def create
  FileUtils.touch("acl1.txt")
  `chmod +a "guest deny readattr" acl1.txt`

  FileUtils.touch("acl2.txt")
  `chmod +a "guest deny readextattr" acl2.txt`

  FileUtils.touch("acl3.txt")
  `chmod +a "guest deny readsecurity" acl3.txt`
end

def verify(original_dir)
  errors = %w(A B C)
  errors << 'X' unless FileTest.exist?("acl1.txt")
  errors << 'X' unless FileTest.exist?("acl2.txt")
  errors << 'X' unless FileTest.exist?("acl3.txt")
  s = `ls -le`
  errors.delete('A') if s =~ /guest deny readattr/
  errors.delete('B') if s =~ /guest deny readextattr/
  errors.delete('C') if s =~ /guest deny readsecurity/
  { :errors => errors.uniq }
end
