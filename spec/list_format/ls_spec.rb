# frozen_string_literal: true

require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Ftpd
  module ListFormat

    describe Ls do

      let(:file_info) do
        FileInfo.new(:ftype => 'file',
                     :group => 'group',
                     :mode => 0100644,
                     :mtime => Time.mktime(2013, 3, 3, 8, 38, 0),
                     :nlink => 1,
                     :owner => 'user',
                     :path => 'foo',
                     :size => 1234)
      end
      subject(:formatter) {Ls.new(file_info)}

      it 'should approximate ls -l format' do
        Timecop.freeze(2013, 3, 3, 8, 38, 0) do
          expect(formatter.to_s).to eq \
          '-rw-r--r-- 1 user     group        1234 Mar  3 08:38 foo'
        end
      end

    end

    describe Ls::FileType do

      [
        ['file', '-'],
        ['directory', 'd'],
        ['characterSpecial', 'c'],
        ['blockSpecial', 'b'],
        ['fifo', 'p'],
        ['link', 'l'],
        ['socket', 's'],
        ['unknown', '?'],
      ].each do |ftype, letter|
        context "(#{ftype})" do
          specify do
            expect(Ls::FileType.letter(ftype)).to eq letter
          end
        end
      end

    end

    describe Ls::FileMode do

      let(:other_execute) {0}
      let(:other_write) {0}
      let(:other_read) {0}
      let(:group_execute) {0}
      let(:group_write) {0}
      let(:group_read) {0}
      let(:owner_execute) {0}
      let(:owner_write) {0}
      let(:owner_read) {0}
      let(:sticky) {0}
      let(:setgid) {0}
      let(:setuid) {0}
      let(:mode) do
        other_execute << 0 |
          other_write << 1 |
          other_read << 2 |
          group_execute << 3 |
          group_write << 4 |
          group_read << 5 |
          owner_execute << 6 |
          owner_write << 7 |
          owner_read << 8 |
          sticky << 9 |
          setgid << 10 |
          setuid << 11
      end

      let(:letters) {Ls::FileMode.new(mode).letters}

      describe 'owner read' do
        subject {letters[0..0]}
        context '(0)' do
          let(:owner_read) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:owner_read) {1}
          it {should == 'r'}
        end
      end

      describe 'owner write' do
        subject {letters[1..1]}
        context '(0)' do
          let(:owner_write) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:owner_write) {1}
          it {should == 'w'}
        end
      end

      describe 'owner execute' do

        subject {letters[2..2]}

        context '(setuid 0)' do
          let(:setuid) {0}
          context '(execute 0)' do
            let(:owner_execute) {0}
            it {should == '-'}
          end
          context '(execute 1)' do
            let(:owner_execute) {1}
            it {should == 'x'}
          end
        end

        context '(setuid 1)' do
          let(:setuid) {1}
          context '(execute 0)' do
            let(:owner_execute) {0}
            it {should == 'S'}
          end
          context '(execute 1)' do
            let(:owner_execute) {1}
            it {should == 's'}
          end
        end

      end

      describe 'group read' do
        subject {letters[3..3]}
        context '(0)' do
          let(:group_read) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:group_read) {1}
          it {should == 'r'}
        end
      end

      describe 'group write' do
        subject {letters[4..4]}
        context '(0)' do
          let(:group_write) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:group_write) {1}
          it {should == 'w'}
        end
      end

      describe 'group execute' do

        subject {letters[5..5]}

        context '(setgid 0)' do
          let(:setgid) {0}
          context '(execute 0)' do
            let(:group_execute) {0}
            it {should == '-'}
          end
          context '(execute 1)' do
            let(:group_execute) {1}
            it {should == 'x'}
          end
        end

        context '(setgid 1)' do
          let(:setgid) {1}
          context '(execute 0)' do
            let(:group_execute) {0}
            it {should == 'S'}
          end
          context '(execute 1)' do
            let(:group_execute) {1}
            it {should == 's'}
          end
        end

      end

      describe 'other read' do
        subject {letters[6..6]}
        context '(0)' do
          let(:other_read) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:other_read) {1}
          it {should == 'r'}
        end
      end

      describe 'other write' do
        subject {letters[7..7]}
        context '(0)' do
          let(:other_write) {0}
          it {should == '-'}
        end
        context '(1)' do
          let(:other_write) {1}
          it {should == 'w'}
        end
      end

      describe 'other execute' do

        subject {letters[8..8]}

        context '(sticky 0)' do
          let(:sticky) {0}
          context '(execute 0)' do
            let(:other_execute) {0}
            it {should == '-'}
          end
          context '(execute 1)' do
            let(:other_execute) {1}
            it {should == 'x'}
          end
        end

        context '(sticky 1)' do
          let(:sticky) {1}
          context '(execute 0)' do
            let(:other_execute) {0}
            it {should == 'T'}
          end
          context '(execute 1)' do
            let(:other_execute) {1}
            it {should == 't'}
          end
        end

      end

    end

    describe '.format_time' do

      let(:mtime) {Time.mktime(2013, 6, 1, 13, 14, 15)}

      around(:each) { |block| Timecop.freeze(now, &block) }
      subject {Ls.format_time(mtime)}

      context '(recent)' do
        let(:now) {mtime}
        it {should == 'Jun  1 13:14'}
      end

      context '(old)' do
        let(:now) {Time.mktime(2014, 1, 1, 0, 0, 0)}
        it {should == 'Jun  1  2013'}
      end

      context '(future)' do
        let(:now) {Time.mktime(2013, 1, 1, 0, 0, 0)}
        it {should == 'Jun  1  2013'}
      end

    end

  end
end
