=begin
Uses "xbup" by Victor Shoup
http://www.shoup.net/xbup/
=end
PATH_RSYNC = "/usr/bin/rsync"
PATH_XBUP_SPLIT = File.expand_path("~/bin/splitf_xattr")
PATH_XBUP_JOIN = File.expand_path("~/bin/joinf_xattr")

def name
  'xbup'
end

def is_installed
  File.exists?(PATH_RSYNC) &&
    File.exists?(PATH_XBUP_JOIN) &&
    File.exists?(PATH_XBUP_SPLIT)
end

def version
  # `#{PATH} --version`.strip
  true
end

def print_full_version
  # system "#{PATH} --version"
  puts "todo"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["SOURCE_DIR"] = source_dir
  s = <<CMD
sudo #{PATH_RSYNC} -aH --rsync-path=#{PATH_RSYNC} "$SOURCE_DIR"/ "$DEST_DIR" 
sudo #{PATH_XBUP_SPLIT} --crtime --acl "$SOURCE_DIR" | sudo #{PATH_XBUP_JOIN} --acl "$DEST_DIR"
CMD
  puts s
  puts "------------"
  system s
end

=begin
rsync=/usr/bin/rsync # path to rsync 
xattr=... # path to xbup tools 
flags="-aH --rsync-path=$rsync" 
# Should exit with code 0 if the necessary programs exist, 1 otherwise 
can-copy () { 
test -e $rsync 
} 
# Should generate some text on stdout identifying which version of the 
# copier is being used, and how it’s called. This is optional. 
version () { 
$rsync --version 
echo 
echo "command = sudo $rsync $flags src/ dst" 
} 
# Should perform a copy from $1 to $2. Both will be directories. Neither 
# will end with ’/’. So you’ll get something like: 
# backup /Volumes/Src /Volumes/Dst/99-foo 
backup () { 
sudo $rsync $flags $1/ $2 
sudo $xattr/splitf_xattr --crtime --acl $1 | sudo $xattr/joinf_xattr --acl $2 
}
=end