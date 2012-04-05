def hdiutil_create_sparseimage(name)
  system(
    "hdiutil", "create", 
    "-size", "1000m", 
    "-fs", "Journaled HFS+", 
    "-volname", name,
    "-type", "SPARSE",
    "./#{name}"
  )
end

def hdiutil_mount_sparseimage(name)
  system(
    "hdiutil", "mount",
    "-owners", "on",
    "./#{name}.sparseimage"
  )
end

def hdiutil_unmount(name)
  system("sudo", "hdiutil", "unmount", "/Volumes/#{name}")
end

def hdiutil_unmount_force(name)
  system("sudo", "hdiutil", "unmount", "/Volumes/#{name}", "-force")
end

def create_and_mount_volume(name)
  if FileTest.exist?("/Volumes/#{name}")
    # puts "volume already exist"
    return
  end
  unless FileTest.exist?("./#{name}.sparseimage")
    hdiutil_create_sparseimage(name)
  end

  hdiutil_mount_sparseimage(name)
  
  # enable access control lists on our volume
  # on Snow Leopard + Lion this is enabled by default
  # system("sudo", "fsaclctl", "-p", "/Volumes/#{name}", "-e")

  # make it easy to detect if the volume is ours
  FileUtils.touch("/Volumes/#{name}/AnalyzeCopy-Volume")
end
