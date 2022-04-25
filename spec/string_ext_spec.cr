require "./spec_helper"

describe String do
  it "can left pad correctly" do
    "12345".lpad(10).should eq "     12345"
    "1234567890".lpad(10).should eq "1234567890"
    "1234567890".lpad(8).should eq "34567890"
    "123".lpad(10, "0").should eq "0000000123"
    "abcd".lpad(20, "123").should eq "1231231231231231abcd"
    "1".lpad(2, '0').should eq "01"
  end

  it "can right pad correctly" do
    "12345".rpad(10).should eq "12345     "
    "1234567890".rpad(10).should eq "1234567890"
    "1234567890".rpad(8).should eq "12345678"
    "123".rpad(10, "0").should eq "1230000000"
    "abcd".rpad(20, "123").should eq "abcd1231231231231231"
  end
end
