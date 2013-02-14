require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe DiskFileSystem do

    let(:data_dir) {Ftpd::TempDir.make}
    let(:disk_file_system) {DiskFileSystem.new(data_dir)}

    def data_path(path)
      File.join(data_dir, path)
    end

    def directory(path)
      Dir.mkdir data_path(path)
    end

    def file(path)
      File.open(data_path(path), 'w') do |file|
        file.write contents(path)
      end
    end

    def exists?(path)
      File.exists?(data_path(path))
    end

    def contents(path)
      "Contents of #{path}"
    end

    before(:each) do
      directory 'dir'
      file 'file'
      directory 'unwritable_dir'
      file 'unwritable_dir/file'
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
            disk_file_system.delete('nosuchfile')
          }.to raise_error Ftpd::FileSystemError, /No such file or directory/
        end
      end

    end

  end
end
