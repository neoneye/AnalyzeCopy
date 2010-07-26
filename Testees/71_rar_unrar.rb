RAR_PATH = File.expand_path("~/bin/rar")
UNRAR_PATH = File.expand_path("~/bin/unrar")

def is_installed
  File.exists?(RAR_PATH) && File.exists?(UNRAR_PATH)
end

def version
  `#{RAR_PATH}`.grep(/opyri/)[0].match(/^(RAR\s\d+\.\d+)/).to_s + "\n" +
  `#{UNRAR_PATH}`.grep(/opyri/)[0].match(/^(UNRAR\s\d+\.\d+)/).to_s
end

def print_full_version
  puts "todo"
end

def copy_data(source_dir, dest_dir)
  ENV["RAR_FILE"] = File.join(dest_dir, "testdata")
  ENV["SOURCE_DIR"] = source_dir
  ENV["DEST_DIR"] = dest_dir
  s = <<CMD
mkdir "$DEST_DIR"
cd "$SOURCE_DIR"
sudo #{RAR_PATH} a -r -tk -tsm -tsc -ol "$RAR_FILE"
cd "$DEST_DIR"
sudo #{UNRAR_PATH} x -y -tsm -tsc "$RAR_FILE"
CMD
  puts s
  puts "------------"
  system s
end
