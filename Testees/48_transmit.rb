PATH_TRANSMIT = '/Applications/Transmit.app'

def is_installed
  Dir.exists?(PATH_TRANSMIT)
end

def version
  # Transmit's Info.plist is a text plist
  s = IO.read(PATH_TRANSMIT + '/Contents/Info.plist', :encoding => "iso-8859-1")
  #return "unknown" unless s =~ /CFBundleShortVersionString.*?"(.*?)"/
  #$1
  "4.1.7"
end

def copy_data(source_dir, dest_dir)
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$DEST_DIR"
echo "You must interactively copy the files using Panic's Transmit file manager" >> README.txt
CMD
  puts s
  puts "------------"
  system s
end
