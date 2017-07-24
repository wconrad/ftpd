# frozen_string_literal: true

class TestFileTemplates

  def [](filename)
    if have_template?(filename)
      read_template filename
    else
      default_template filename
    end
  end

  private

  def have_template?(filename)
    File.exist?(template_path(filename))
  end

  def read_template(filename)
    File.open(template_path(filename), 'rb', &:read)
  end

  def template_path(filename)
    File.expand_path(filename, templates_path)
  end

  def templates_path
    File.expand_path('file_templates', File.dirname(__FILE__))
  end

  def default_template(filename)
    "Contents of #{filename}"
  end

end
