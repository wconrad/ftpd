module Ftpd
  module PathHelper
    def self.expand_path(file_name, dir_string)
      File.expand_path(file_name, dir_string)
      
      if file_name.start_with?("/") or file_name.start_with?("\\") then
        parts = file_name.split(/[\/\\]/)
      else
        parts = dir_string.split(/[\/\\]/) + file_name.split(/[\/\\]/)
      end

      new_parts = []
      parts.each do |p|
        case p
        when ""
        when "."
        when ".."
          new_parts.pop
        else
          new_parts << p
        end
      end

      "/" + new_parts.join("/")
    end
  end
end

