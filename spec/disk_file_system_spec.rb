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

    def read_only path
      File.chmod 0500, data_path(path)
    end

    def writable path
      File.chmod 0700, data_path(path)
    end

    def touch(path)
      FileUtils.touch data_path(path)
    end

    def exists?(path)
      File.exists?(data_path(path))
    end

    before(:each) do
      mkdir 'dir'
      touch 'file'
      mkdir 'unwritable_dir'
      touch 'unwritable_dir/file'
      read_only 'unwritable_dir'
    end

    after(:each) do
      writable 'unwritable_dir'
    end

    describe '#accessible?' do

      context '(within tree)' do
        specify do
          disk_file_system.accessible?('file').should be_true
        end
      end

      context '(outside tree)' do
        specify do
          disk_file_system.accessible?('../outside').should be_false
        end
      end

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

    describe '#delete' do

      context '(normal)' do
        specify do
          disk_file_system.delete('file')
          exists?('file').should be_false
        end
      end

      context '(permission denied)' do
        specify do
          expect {
            disk_file_system.delete('unwritable_dir/file')
          }.to raise_error Ftpd::FileSystemError, /Permission denied/
        end
      end

    end

  end
end
