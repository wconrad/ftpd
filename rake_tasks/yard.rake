if Gem::Specification::find_all_by_name("yard").any?

  require 'yard'
  YARD::Rake::YardocTask.new do |t|
  end

end
