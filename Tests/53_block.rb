def is_installed
  true
end

def create
  `sudo mknod my_vn0_block_node b 1 0`
end

def verify(original_dir)
  errors = %w(A B)
  if FileTest.exist?("my_vn0_block_node")
    errors.delete('B')
    if File.stat("my_vn0_block_node").ftype == "blockSpecial"
      errors.delete('A')
    end
  end
  { :errors => errors }
end
