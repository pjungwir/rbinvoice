require 'rbinvoice'

describe "Options" do

  it "should have good defaults" do
    opts = RbInvoice::parse_command_line(['my-client'])
    opts[:client].should == 'my-client'
  end

end
