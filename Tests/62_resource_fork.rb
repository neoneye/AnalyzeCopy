=begin

only files can have resource fork.

I have tried adding resource fork to dirs, fifos, and symlinks,
but without luck.

=end
PATH = File.join(Dir.pwd, "utils", "ac_setresource")

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH}`.split("\n")[0].strip
end

def create
#  File.open("test.txt", "w+") {|f| f.write("im data") }
#  File.open("test.txt/rsrc", "w+") {|f| f.write("im rsrc") }

  # all tools seems to be happy with 40 mb of resource fork
#  File.open("data.txt", "w+") do |f| 
#    s = "\0" * 1000000
#    40.times do |i|
#      f.write "mark #{i}"
#      f.write s
#    end
#  end

  #
  #
  #
  File.open("data.txt", "w+") {|f| 
    f.write("the data we want to use in resource fork") }
  `touch file_with_rsrc`
  `#{PATH} data.txt file_with_rsrc`

  File.open("hl1", "w+") {|f| f.write("im a hardlink") }
  `ln hl1 hl2`
  `#{PATH} data.txt hl1`
end

def verify(original_dir)
  errors = %w(A B C D X Y Z)
  if FileTest.exist?("file_with_rsrc")
    errors.delete('X')
    errors.delete('Y') if FileUtils.compare_file(
      "file_with_rsrc", File.join(original_dir, "file_with_rsrc"))
    errors.delete('D') if FileUtils.compare_file(
      "file_with_rsrc/..namedfork/rsrc", "data.txt")
  end
  if FileTest.exist?("hl1") && FileTest.exist?("hl2")
    errors.delete('Z')
    ino1 = File.stat("hl1").ino
    ino2 = File.stat("hl2").ino
    errors.delete('A') if ino1 == ino2
    errors.delete('B') if FileUtils.compare_file("hl1/..namedfork/rsrc", "data.txt")
    errors.delete('C') if FileUtils.compare_file("hl2/..namedfork/rsrc", "data.txt")
  end
  { :errors => errors }
end
