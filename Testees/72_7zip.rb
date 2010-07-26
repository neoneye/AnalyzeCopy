#
# 7-zip can be installed via Mac Ports
# sudo port install p7zip 
#
PATH = "/opt/local/bin/7za"

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH}`.grep(/opyri/)[0].match(/^(.*?\s\d+\.\d+)/).to_s
end

def print_full_version
  puts "todo"
end

def copy_data(source_dir, dest_dir)
  ENV["SOURCE_DIR"] = source_dir
  ENV["SOURCE_DIRNAME"] = File.basename(source_dir)
  ENV["DEST_DIR"] = dest_dir
  ENV["DEST_DIR_TMP"] = dest_dir + "_tmp" 
  
  s = <<CMD
mkdir "$DEST_DIR_TMP"
cd "$DEST_DIR_TMP"
sudo #{PATH} a -r testdata.7z "$SOURCE_DIR"
sudo #{PATH} x -y testdata.7z
sudo mv "$SOURCE_DIRNAME" "$DEST_DIR" 
CMD
  puts s
  puts "------------"
  system s
end
