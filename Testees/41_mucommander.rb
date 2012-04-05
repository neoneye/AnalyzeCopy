PATH_MUCOMMANDER = '/Applications/muCommander.app'

def name
  'muCommander'
end

def is_installed
  Dir.exists?(PATH_MUCOMMANDER)
end

def version
  # muCommander's Info.plist is an XML plist
  s = IO.read(PATH_MUCOMMANDER + '/Contents/Info.plist')
  return "unknown" unless s =~ /CFBundleShortVersionString.*?<string>(.*?)<\/string>/m
  $1
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using muCommander" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
