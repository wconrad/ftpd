# frozen_string_literal: true

module Ftpd
  describe FileInfo do

    subject {FileInfo.new(opts)}

    def self.it_has_attribute(attribute)
      describe "##{attribute}" do
        let(:value) {"#{attribute} value"}
        let(:opts) {{attribute => value}}
        its(attribute) {should == value}
      end
    end

    it_has_attribute :ftype
    it_has_attribute :group
    it_has_attribute :identifier
    it_has_attribute :mode
    it_has_attribute :mtime
    it_has_attribute :nlink
    it_has_attribute :owner
    it_has_attribute :path
    it_has_attribute :size

    describe '#file?' do

      let(:opts) {{:ftype => ftype}}

      context '(file)' do
        let(:ftype) {'file'}
        its(:file?) {should be_truthy}
      end

      context '(directory)' do
        let(:ftype) {'directory'}
        its(:file?) {should be_falsey}
      end

    end

    describe '#directory?' do

      let(:opts) {{:ftype => ftype}}

      context '(file)' do
        let(:ftype) {'file'}
        its(:directory?) {should be_falsey}
      end

      context '(directory)' do
        let(:ftype) {'directory'}
        its(:directory?) {should be_truthy}
      end

    end

  end
end
