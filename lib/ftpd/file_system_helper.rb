# frozen_string_literal: true

module Ftpd

  module FileSystemHelper

    def path_list(path)
      if file_system.directory?(path)
        path = File.join(path, '*')
      end
      file_system.dir(path).sort
    end

    def ensure_file_system_supports(method)
      unless file_system.respond_to?(method)
        unimplemented_error
      end
    end

    def ensure_accessible(path)
      unless file_system.accessible?(path)
        error 'Access denied', 550
      end
    end

    def ensure_exists(path)
      unless file_system.exists?(path)
        error 'No such file or directory', 550
      end
    end

    def ensure_does_not_exist(path)
      if file_system.exists?(path)
        error 'Already exists', 550
      end
    end

    def ensure_directory(path)
      unless file_system.directory?(path)
        error 'Not a directory', 550
      end
    end

    def unique_path(path)
      suffix = nil
      100.times do
        path_with_suffix = [path, suffix].compact.join('.')
        unless file_system.exists?(path_with_suffix)
          return path_with_suffix
        end
        suffix = generate_suffix
      end
      raise "Unable to find unique path"
    end

    private

    def generate_suffix
      set = ('a'..'z').to_a
      8.times.map do
        set[rand(set.size)]
      end.join
    end

  end

end
