# frozen_string_literal: true

# -*- ruby encoding: us-ascii -*-

require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe Telnet do

    IAC  = 255.chr    # 0xff
    DONT = 254.chr    # 0xfe
    DO   = 253.chr    # 0xfd
    WONT = 252.chr    # 0xfc
    WILL = 251.chr    # 0xfb
    IP   = 244.chr    # 0xf4
    DM   = 242.chr    # 0xf2

    subject {Telnet.new(command)}
    let(:plain_command) {"NOOP\r\n"}
    let(:command) {codes + plain_command}

    context '(plain command)' do
      let(:codes) {''}
      its(:reply) {should == ''}
      its(:plain) {should == plain_command}
    end

    context '(escaped IAC)' do
      let(:codes) {"#{IAC}#{IAC}"}
      its(:reply) {should == ''}
      its(:plain) {should == "#{IAC}" + plain_command}
    end

    context '(IAC + unknown code)' do
      let(:codes) {"#{IAC}\x01"}
      its(:reply) {should == ''}
      its(:plain) {should == codes + plain_command}
    end

    context '(WILL)' do
      let(:codes) {"#{IAC}#{WILL}\x01"}
      its(:reply) {should == "#{IAC}#{DONT}\x01"}
      its(:plain) {should == plain_command}
    end

    context '(WONT)' do
      let(:codes) {"#{IAC}#{WONT}\x01"}
      its(:reply) {should == ''}
      its(:plain) {should == plain_command}
    end

    context '(DO)' do
      let(:codes) {"#{IAC}#{DO}\x01"}
      its(:reply) {should == "#{IAC}#{WONT}\x01"}
      its(:plain) {should == plain_command}
    end

    context '(DONT)' do
      let(:codes) {"#{IAC}#{DONT}\x01"}
      its(:reply) {should == ''}
      its(:plain) {should == plain_command}
    end

    context '(interrupt process)' do
      let(:codes) {"#{IAC}#{IP}"}
      its(:reply) {should == ''}
      its(:plain) {should == plain_command}
    end

    context '(data mark)' do
      let(:codes) {"#{IAC}#{DM}"}
      its(:reply) {should == ''}
      its(:plain) {should == plain_command}
    end

  end
end
