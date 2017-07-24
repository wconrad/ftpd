# frozen_string_literal: true

module TestServerFiles

  def add_file(path)
    full_path = temp_path(path)
    mkdir_p File.dirname(full_path)
    File.open(full_path, 'wb') do |file|
      file.write @templates[File.basename(full_path)]
    end
  end

  def set_mtime(path, mtime)
    full_path = temp_path(path)
    File.utime(File.atime(full_path), mtime, full_path)
  end

  def add_directory(path)
    full_path = temp_path(path)
    mkdir_p full_path
  end

  def has_file?(path)
    full_path = temp_path(path)
    File.exist?(full_path)
  end

  def has_file_with_contents_of?(path)
    expected_contents = @templates[File.basename(path)]
    all_paths.any? do |path|
      File.open(path, 'rb', &:read) == expected_contents
    end
  end

  def files_named_like(name)
    all_paths.select do |path|
      path.include?(name)
    end
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

  def all_paths
    Dir[temp_path('**/*')]
  end

end
