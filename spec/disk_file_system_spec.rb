# frozen_string_literal: true

module Ftpd
  describe DiskFileSystem do

    let(:data_dir) {Ftpd::TempDir.make}
    let(:disk_file_system) {DiskFileSystem.new(data_dir)}
    let(:missing_file_error) do
      [Ftpd::PermanentFileSystemError, /No such file or directory/]
    end
    let(:is_a_directory_error) do
      [Ftpd::PermanentFileSystemError, /Is a directory/]
    end
    let(:missing_path) {'missing_path'}

    def data_path(path)
      File.join(data_dir, path)
    end

    def make_directory(path)
      Dir.mkdir data_path(path)
    end

    def write_file(path)
      File.open(data_path(path), 'wb') do |file|
        file.write canned_contents(path)
      end
    end

    def read_file(path)
      File.open(data_path(path), 'rb', &:read)
    end

    def directory?(path)
      File.directory?(data_path(path))
    end

    def exists?(path)
      File.exist?(data_path(path))
    end

    def canned_contents(path)
      "Contents of #{path}"
    end

    def add_symlink(target_path, symlink_path)
      FileUtils.ln_s data_path(target_path), data_path(symlink_path)
    end

    before(:each) do
      write_file 'file'
      make_directory 'dir'
      write_file 'dir/file_in_dir'
      make_directory 'unwritable_dir'
      write_file 'unwritable_dir/file'
      add_symlink 'file', 'symlink'
    end

    describe '#accessible?' do

      context '(within tree)' do
        specify do
          expect(disk_file_system.accessible?('file')).to be_truthy
        end
      end

      context '(outside tree)' do
        specify do
          expect(disk_file_system.accessible?('../outside')).to be_falsey
        end
      end

    end

    describe '#exists?' do

      context '(exists)' do
        specify do
          expect(disk_file_system.exists?('file')).to be_truthy
        end
      end

      context '(does not exist)' do
        specify do
          expect(disk_file_system.exists?('missing')).to be_falsey
        end
      end

    end

    describe '#directory?' do

      context '(directory)' do
        specify do
          expect(disk_file_system.directory?('file')).to be_falsey
        end
      end

      context '(file)' do
        specify do
          expect(disk_file_system.directory?('dir')).to be_truthy
        end
      end

    end

    describe '#delete' do

      context '(success)' do
        specify do
          disk_file_system.delete('file')
          expect(exists?('file')).to be_falsey
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.delete(missing_path)
          }.to raise_error(*missing_file_error)
        end
      end

    end

    describe '#read' do

      context '(success)' do
        let(:path) {'file'}
        specify do
          disk_file_system.read(path) do |file|
            expect(file).to be_a(IO)
            expect(file.read).to eq canned_contents(path)
          end
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.read(missing_path) {}
          }.to raise_error(*missing_file_error)
        end
      end

    end

    describe '#write' do

      let(:contents) {'file contents'}
      let(:stream)   {Ftpd::Stream.new(StringIO.new(contents), nil)}

      context '(success)' do
        let(:path) {'file_path'}
        specify do
          disk_file_system.write(path, stream)
          expect(read_file(path)).to eq contents
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.write('dir', stream)
          }.to raise_error(*is_a_directory_error)
        end
      end

    end

    describe '#append' do

      let(:contents) {'file contents'}
      let(:stream)   {Ftpd::Stream.new(StringIO.new(contents), nil)}

      context '(destination missing)' do
        let(:path) {'file_path'}
        specify do
          disk_file_system.append(path, stream)
          expect(read_file(path)).to eq contents
        end
      end

      context '(destination exists)' do
        let(:path) {'file'}
        specify do
          disk_file_system.append(path, stream)
          expect(read_file(path)).to eq canned_contents(path) + contents
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.append('dir', stream)
          }.to raise_error(*is_a_directory_error)
        end
      end

    end

    describe '#mkdir' do

      context '(success)' do
        let(:path) {'another_subdir'}
        specify do
          disk_file_system.mkdir(path)
          expect(directory?(path)).to be_truthy
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.mkdir('file')
          }.to raise_error PermanentFileSystemError, /^File exists/
        end
      end

    end

    describe '#rename' do

      let(:from_path) {'file'}
      let(:to_path) {'renamed_file'}

      context '(success)' do
        specify do
          disk_file_system.rename(from_path, to_path)
          expect(exists?(from_path)).to be_falsey
          expect(exists?(to_path)).to be_truthy
        end
      end

      context '(error)' do
        specify do
          expect {
            disk_file_system.rename(missing_path, to_path)
          }.to raise_error(*missing_file_error)
        end
      end

    end

    describe '#file_info' do

      let(:identifier) {"#{stat.dev}.#{stat.ino}"}
      let(:owner) {Etc.getpwuid(stat.uid).name}
      let(:group) {Etc.getgrgid(stat.gid).name}
      let(:stat) {File.stat(data_path(path))}
      subject {disk_file_system.file_info(path)}

      shared_examples 'file info' do
        its(:ftype) {should == stat.ftype}
        its(:group) {should == group}
        its(:mode) {should == stat.mode}
        its(:mtime) {should == stat.mtime}
        its(:nlink) {should == stat.nlink}
        its(:owner) {should == owner}
        its(:size) {should == stat.size}
        its(:path) {should == path}
        its(:identifier) {should == identifier}
      end

      context '(file)' do
        let(:path) {'file'}
        it_behaves_like 'file info'
      end

      context '(symlink)' do
        let(:path) {'symlink'}
        it_behaves_like 'file info'
      end

    end

    describe '#dir' do

      subject(:dir) do
        disk_file_system.dir(path)
      end

      context '(no such file)' do
        let(:path) {'missing'}
        it {should be_empty}
      end

      context '(file)' do
        let(:path) {'file'}
        it {should include '/file'}
      end

      context '(directory)' do
        let(:path) {'dir'}
        it {should include '/dir'}
        it {should_not include '/dir/file_in_dir'}
      end

      context '(directory + wildcard)' do
        let(:path) {'dir/*'}
        it {should_not include '/dir'}
        it {should include '/dir/file_in_dir'}
      end

      context '(wildcard)' do
        let(:path) {'*'}
        it {should include '/unwritable_dir'}
        it {should include '/file'}
        it {should include '/dir'}
      end

      context '(no such directory)' do
        let(:path) {'foo/*'}
        it {should be_empty}
      end

    end

  end
end
