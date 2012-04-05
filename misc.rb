# example of the string returned: "Mac OS X 10.5.8 (9L31a)"
def obtain_system_version
  "%s %s (%s)" % (`sw_vers`.scan(/:\s+(.*?)$/m)).flatten
end
