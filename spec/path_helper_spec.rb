require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe PathHelper do
    describe :expand_path do
      it "should return root path if given two empty paths" do
        PathHelper.expand_path("", "").should == "/"
      end

      it "should return parent if file_name is .." do
        PathHelper.expand_path("..", "/foo/bar").should == "/foo"
      end


      it "should return same if file_name is ." do
        PathHelper.expand_path(".", "/foo/bar").should == "/foo/bar"
      end

      it "should return subdir with single element file_name" do
        PathHelper.expand_path("baz", "/foo/bar").should == "/foo/bar/baz"
      end

      it "should return subdir with file_name starting with ./" do
        PathHelper.expand_path("./baz", "/foo/bar").should == "/foo/bar/baz"
      end

      it "should handle incorporated .. in file_name" do
        PathHelper.expand_path("../baz", "/foo/bar").should == "/foo/baz"
      end

      it "should handle extra .. in file_name" do
        PathHelper.expand_path("../../../../../baz", "/foo/bar").should == "/baz"
      end

      it "it should return file_name if it is absolute path" do
        PathHelper.expand_path("/foo/bar/baz", "/should/ignore/me").should == "/foo/bar/baz"
      end
    end
  end
end

