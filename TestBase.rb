class TestBase
  FILENAME = nil
  NAME = nil

  # determines if the required tools are installed, 
  # so this test can be executed
  def is_installed
    false
  end
  
  # sometimes we use an external tool to conduct the test,
  # such tool could be SetFile, chmod, perl.
  # this method returns the version number
  def version
    "sometool 6.6.6"
  end

  # generate testdata in the current dir. This function usually
  # invokes mkdir and touch followed by chmod/chown/SetFile
  # the whole purpose with this function is to make some 
  # data that are difficult or impossible to copy
  def create
    # generate evil files
  end

  # get rid of evil files that we created in the current dir
  # "rm" doesn't like locked files, so you must unlock them here
  def clean
    # unlock files 
  end

  # compare the files in the current dir with files in another dir
  # always return a dictionary, containing an :errors => array of strings
  # if the compared files are identical then return :errors => []
  # if they differ then return :errors => ['A', 'B', 'C']
  #   where A B C are the locations where the comparison failed
  def verify(original_dir)
    # verify that current dir have the same properties that we created
    { :errors => %w(xxx) }
  end
end