require 'rbinvoice'

describe "Options" do

  it "should have good defaults" do
    client, out_filename, opts = RbInvoice::parse_command_line(%w{--no-rcfile --no-data-dir my-client outfile})
    client.should == 'my-client'
    out_filename.should == 'outfile'
  end

  it "should require an output filename if it can't infer one" do
    lambda {
      RbInvoice::parse_command_line(%w{--no-rcfile --no-data-dir my-client})
    }.should raise_error SystemExit
  end

end
