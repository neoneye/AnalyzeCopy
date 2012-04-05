=begin

Tim Kientzle: I would suggest you split this into a separate test, since this is related to an Apple convention for using "._" as a special file prefix.
Simon Strandgaard: Thank you. I have created a new test for "._"

=end

def is_installed
  true
end

# names containing possibly dangerous ascii letters
NAMES = [
  " ",  # space
  "!",  # exclamation mark
  "\"", # double quote
  "#",  # 
  "$",  # dollar
  "%",  # percent sign
  "&",  # ampersand
  "'",  # single quote
  "(",  # parenthesis begin
  ")",  # parenthesis end
  "*",  # asterisk
  "+",  # plus
  ",",  # comma
  "-",  # minus
  ".*", # period asterisk
  # NOTE: forward slash is cannot be used in filenames, so we don't test it
  ":",  # colon
  ";",  # semicolon
  "<",  # less than
  "=",  # equal
  ">",  # greater than
  "?",  # question mark
  "@",  # at
  "[",  # bracket begin
  "\\",  # backslash
  "]",  # bracket end
  "^",  # hat
  "_",  # underscore
  "`",  # tick
  "{",  # curly begin
  "|",  # vertical bar
  "}",  # curly end
  "~",  # tilde
]


def create
  NAMES.each do |name|
    if name == "'"
      `touch "#{name}"`
    else
      `touch '#{name}'`
    end
  end
end

def verify(original_dir)
  errors = []
  NAMES.each do |name|
    ok1 = FileTest.exist?(name)
    ok2 = false
    Dir.chdir(original_dir) do
      ok2 = FileTest.exist?(name)
    end
    errors << 'X' if ok1 != ok2
  end
  { :errors => errors }
end

