require File.expand_path('spec_helper', File.dirname(__FILE__))

describe SymlinkHelper do

  include SymlinkHelper

  context 'when symlink is supported' do
    specify do
      expect(symlink_supported?).to be_true
    end
  end

  context 'when symlink is not supported' do
    specify do
      File.stub(:symlink).and_raise(NotImplementedError)
      expect(symlink_supported?).to be_false
    end
  end

  it 'should be callable as a module function' do
    SymlinkHelper.symlink_supported?
  end

end
