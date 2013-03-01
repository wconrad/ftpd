require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe CommandSequenceChecker do

    let(:sequence_error) {[CommandError, '503 Bad sequence of commands']}
    subject(:checker) {CommandSequenceChecker.new}

    context 'initial' do

      it 'accepts any command' do
        checker.check 'NOOP'
      end

    end

    context 'when a specific command is expected' do
      
      before(:each) {checker.expect 'PASS'}

      it 'accepts that command' do
        checker.check 'PASS'
      end

      it 'rejects any other command' do
        expect {
          checker.check 'NOOP'
        }.to raise_error *sequence_error
      end

    end

    context 'after the expected command has arrived' do

      before(:each) do
        checker.expect 'PASS'
        checker.check 'PASS'
      end

      it 'accepts any other command' do
        checker.check 'NOOP'
      end

    end

    context 'after a command is rejected' do

      before(:each) do
        checker.expect 'PASS'
        expect {
          checker.check 'NOOP'
        }.to raise_error *sequence_error
      end

      it 'accepts any other command' do
        checker.check 'NOOP'
      end

    end

    context 'when a command must be expected' do

      before(:each) do
        checker.must_expect 'PASS'
      end

      it 'rejects that command if not expected' do
        expect {
          checker.check 'PASS'
        }.to raise_error *sequence_error
      end

      it 'accepts that command when it is accepted' do
        checker.expect 'PASS'
        checker.check 'PASS'
      end

    end

  end
end
