require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe DiskFileSystem do

    let(:temp_dir) {Ftpd::TempDir.make}
    let(:data_dir) {File.join(temp_dir, 'data_dir')}
    let(:disk_file_system) {DiskFileSystem.new(data_dir)}

    def data_path(path)
      File.join(data_dir, path)
    end

    before(:each) do
      Dir.mkdir data_dir
      Dir.mkdir data_path('dir')
      FileUtils.touch data_path('../outside')
      FileUtils.touch data_path('file')
    end

    describe '#exists?' do

      context '(exists)' do
        specify do
          disk_file_system.exists?('file').should be_true
        end
      end

      context '(does not exist)' do
        specify do
          disk_file_system.exists?('missing').should be_false
        end
      end

      context '(outside of directory)' do
        specify do
          disk_file_system.exists?('../outside').should be_false
        end
      end

    end

    describe '#directory?' do

      context '(directory)' do
        specify do
          disk_file_system.directory?('file').should be_false
        end
      end

      context '(file)' do
        specify do
          disk_file_system.directory?('dir').should be_true
        end
      end

    end

  end
end
