def is_installed
  true
end

def create
  File.open("empty.txt", "w+") { }

  File.open("small.txt", "w+") {|f| f.write("lorem ipsum") }

  File.open("big.txt", "w+") do |f| 
    1000.times {|i| 
      f.write("blah blah\n") if (i % 50) == 0
      f.write("#{i} bottles of beer\n")
    }
  end
end

def same_content(original_dir, filename)
  if FileTest.exist?(filename)
    if FileUtils.compare_file(
      filename, File.join(original_dir, filename))
      return true
    end
  end
  false
end

def verify(original_dir)
  errors = %w(A B C)
  errors.delete('C') if same_content(original_dir, "empty.txt")
  errors.delete('B') if same_content(original_dir, "small.txt")
  errors.delete('A') if same_content(original_dir, "big.txt")
  { :errors => errors }
end
