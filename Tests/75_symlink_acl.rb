PATH = File.join(Dir.pwd, "utils", "ac_mklink_acl")

def is_installed
  File.exists?(PATH)
end

def version
  `#{PATH} -v`
end

def create
  `ln -s nonexisting mylink`
  `#{PATH} -a mylink`
end

def verify(original_dir)
  errors = %w(X A)
  if File.lstat("mylink").symlink?
    errors.delete('X')
    s = `ls -lOe mylink`
    if s =~ /allow/m
      errors.delete('A')
    end
  end
  { :errors => errors }
end
