PATH_FORKLIFT = '/Applications/ForkLift.app'

def ignore_tests
  %w(01_permissions)
end

def is_installed
  Dir.exists?(PATH_FORKLIFT)
end

def version
  # ForkLift's Info.plist is an XML plist
  s = IO.read(PATH_FORKLIFT + '/Contents/Info.plist')
  return "unknown" unless s =~ /CFBundleShortVersionString.*?<string>(.*?)<\/string>/m
  $1
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using ForkLift" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
