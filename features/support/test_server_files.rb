module TestServerFiles

  def add_file(path)
    full_path = temp_path(path)
    mkdir_p File.dirname(full_path)
    File.open(full_path, 'wb') do |file|
      file.puts @templates[File.basename(full_path)]
    end
  end

  def add_directory(path)
    full_path = temp_path(path)
    mkdir_p full_path
  end

  def has_file?(path)
    full_path = temp_path(path)
    File.exists?(full_path)
  end

  def has_directory?(path)
    full_path = temp_path(path)
    File.directory?(full_path)
  end

  def file_contents(path)
    full_path = temp_path(path)
    File.open(full_path, 'rb', &:read)
  end

  def temp_path(path)
    File.expand_path(path, temp_dir)
  end

end
