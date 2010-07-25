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
  "._", # period underscore
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

