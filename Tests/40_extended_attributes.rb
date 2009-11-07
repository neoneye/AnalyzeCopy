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

  `touch xattr3.txt`
  `#{PATH} -w com.opcoders.empty_xattr "" xattr3.txt`
end

def verify(original_dir)
  errors = %w(X Y Z A B C)
  if FileTest.exist?("xattr1.txt")
    errors.delete('X')
    s = `#{PATH} -p com.opcoders.analyzecopy_text xattr1.txt`
    if $?.exitstatus != 0
      puts "failed reading xattr"
    elsif s =~ /^hello file world$/
      errors.delete('A')
    end
  end
  if FileTest.exist?("xattr2.dir")
    errors.delete('Y')
    s = `#{PATH} -p com.opcoders.analyzecopy_text xattr2.dir`
    if $?.exitstatus != 0
      puts "failed reading xattr"
    elsif s =~ /^hello dir world$/
      errors.delete('B')
    end
  end
  if FileTest.exist?("xattr3.txt")
    errors.delete('Z')
    s = `#{PATH} xattr3.txt`
    if s =~ /^com.opcoders.empty_xattr$/
      errors.delete('C')
    end
  end
  { :errors => errors }
end
