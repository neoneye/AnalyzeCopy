def is_installed
  true
end

def create

  #
  # this is 100% rip off from Nataniel Gray's excellent Backup Bouncer.
  # in stat64 there is a birthtime that surprisingly many tools doesn't
  # copy at all.
  #
  `touch birthtime.txt`
  # Make sure the creation date isn't the same as the access/modification date
  # The modification date from SetFile is the same as the standard mtime.
  `touch -t 200010101010 birthtime.txt`
  `SetFile -d 12/31/1999 birthtime.txt`
end


def verify(original_dir)
  errors = %w(X A)
  if FileTest.exist?("birthtime.txt")
    errors.delete('X')
    s1 = `GetFileInfo -d birthtime.txt`
    s2 = ''
    Dir.chdir(original_dir) do
      s2 = `GetFileInfo -d birthtime.txt`
    end
    if s1 == s2
      errors.delete('A')
    end
  end
  { :errors => errors }
end
