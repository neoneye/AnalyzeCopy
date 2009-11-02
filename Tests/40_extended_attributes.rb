#
# TODO: are ordering of key|values preserved
# TODO: exercise with duplicates of the same key
# TODO: exercise xattr on symlinks
# TODO: exercise xattr on hardlinks
# TODO: exercise xattr on pipes|fifos|etc
#

PATH = "/usr/bin/xattr"

def is_installed
  File.exists?(PATH)
end

def version
  nil # xattr is versionless
end

def create
  `touch xattr1.txt`
  `#{PATH} -w com.opcoders.analyzecopy_text "hello file world" xattr1.txt`

  `mkdir xattr2.dir`
  `#{PATH} -w com.opcoders.analyzecopy_text "hello dir world" xattr2.dir`
end

def verify(original_dir)
  errors = %w(X Y A B)
  if FileTest.exist?("xattr1.txt")
    errors.delete('X')
    #puts `#{PATH} xattr1.txt`
    s = `#{PATH} -p com.opcoders.analyzecopy_text xattr1.txt`
    if $?.exitstatus != 0
      puts "failed reading xattr"
    end
    #puts "s = #{s.inspect}"
    if s =~ /^hello file world$/
      errors.delete('A')
    end
  end
  if FileTest.exist?("xattr2.dir")
    errors.delete('Y')
    #puts `#{PATH} xattr2.dir`
    s = `#{PATH} -p com.opcoders.analyzecopy_text xattr2.dir`
    if $?.exitstatus != 0
      puts "failed reading xattr"
    end
    #puts "s = #{s.inspect}"
    if s =~ /^hello dir world$/
      errors.delete('B')
    end
  end
  { :errors => errors }
end
