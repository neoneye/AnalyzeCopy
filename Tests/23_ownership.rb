=begin

=end
def is_installed
  true
end

def version
  nil
end

def create
  `touch owned-by-root`
  `sudo chown root:wheel owned-by-root`

  `touch owned-by-www`
  `sudo chown www:www owned-by-www`
end

def is_same(original_dir, filename)
  f1 = filename
  f2 = File.join(original_dir, filename)
  if FileTest.exist?(f1) && FileTest.exist?(f2)
    if File.stat(f1).gid == File.stat(f2).gid
      if File.stat(f1).uid == File.stat(f2).uid
        return true
      end
    end
  end
  false
end

def verify(original_dir)
  errors = %w(A B)
  errors.delete('A') if is_same(original_dir, "owned-by-root")
  errors.delete('B') if is_same(original_dir, "owned-by-www")
  { :errors => errors }
end
