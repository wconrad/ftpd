module SymlinkHelper

  # From:
  # https://github.com/ruby/ruby/blob/trunk/test/fileutils/test_fileutils.rb#L51
  #
  # Via:
  # http://stackoverflow.com/questions/19607326/how-to-tell-if-file-symlink-is-supported

  def symlink_supported?
    File.symlink nil, nil
  rescue NotImplementedError
    return false
  rescue
    return true
  end
  module_function :symlink_supported?

end
