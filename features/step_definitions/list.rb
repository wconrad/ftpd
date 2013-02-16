class FileList

  def initialize(lines)
    @lines = lines
  end

  def filenames
    @lines.map(&:split).map(&:last)
  end

  def long_form?
    @lines.all? do |line|
      line =~ /^[rwxSst-]{10}/
    end
  end

  def short_form?
    !long_form?
  end

  def empty?
    @lines.empty?
  end

end

When /^the client successfully lists the directory(?: "(.*?)")?$/ do |directory|
  @list = FileList.new(@client.ls(*[directory].compact))
end

When /^the client lists the directory( "(?:.*?)")?$/ do |directory|
  capture_error do
    step "the client successfully lists the directory#{directory}"
  end
end

When /^the client successfully name-lists the directory(?: "(.*?)")?$/ do
|directory|
  @list = FileList.new(@client.nlst(*[directory].compact))
end

When /^the client name-lists the directory( "(?:.*?)")?$/ do |directory|
  capture_error do
    step "the client successfully name-lists the directory#{directory}"
  end
end

Then /^the file list should( not)? contain "(.*?)"$/ do |neg, filename|
  matcher = if neg
              :should_not
            else
              :should
            end
  @list.filenames.send(matcher, include(filename))
end

Then /^the file list should be in (long|short) form$/ do |form|
  @list.should send("be_#{form}_form")
end

Then /^the file list should be empty$/ do
  @list.should be_empty
end
