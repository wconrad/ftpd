require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe DiskFileSystem do

    let(:data_dir) {Ftpd::TempDir.make}
    let(:disk_file_system) {DiskFileSystem.new(data_dir)}

    def data_path(path)
      File.join(data_dir, path)
    end

    def mkdir(path)
      Dir.mkdir data_path(path)
    end

    def touch(path)
      FileUtils.touch data_path(path)
    end

    before(:each) do
      mkdir 'file'
      touch 'dir'
    end

    describe '#exists?' do

      context 'exists' do
        specify do
          disk_file_system.exists?('file').should be_true
        end
      end

      context 'does not exist' do
        specify do
          disk_file_system.exists?('missing').should be_false
        end
      end

    end

    describe '#directory?' do

      context 'directory' do
        specify do
          disk_file_system.directory?('file').should be_true
        end
      end

      context 'file' do
        specify do
          disk_file_system.directory?('dir').should be_false
        end
      end

    end

  end
end
