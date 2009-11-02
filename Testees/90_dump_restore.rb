=begin
dump and restore - is not supportet

because "/sbin/dump" only works on FFS volumes.

You get errors on HFS volumes, like this
   DUMP: bad sblock magic number
   DUMP: The ENTIRE dump is aborted.

Still no hfsdump:
http://www.hahnium.com/~pwilk/docs/hfsdump.html
=end

PATH_DUMP = "/sbin/dump"
PATH_RESTORE = "/sbin/restore"

def xis_installed
  File.exists?(PATH_DUMP) && File.exists?(PATH_RESTORE)
end

def version
  "versionless"
end

def print_full_version
  "versionless"
end

def copy_data(source_dir, dest_dir)
  # do nothing
  exit 1
end

def verify(original_dir)
  mask = 1   # Mac OS X's dump doesn't work on HFS+
  {
    :mask => mask
  }
end