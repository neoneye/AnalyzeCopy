# ASR requires a dedicated volume, but I'm too lazy to create one
#
# require "open3"
# 
# PATH = "/usr/sbin/asr"
# 
# def is_installed
#   File.exists?(PATH)
# end
# 
# def version
#   Open3.popen3("#{PATH} version") {|si, so, se| se.read }.strip
# end
