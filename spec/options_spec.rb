require 'rbinvoice'

describe "Options" do

  before :each do
    @tmpdir = "/tmp/rbinvoice-test-#{$$}"
    FileUtils.rm_rf @tmpdir
    FileUtils.mkdir_p @tmpdir
    ENV['HOME'] = @tmpdir
  end

  after :each do
    FileUtils.rm_rf @tmpdir
  end

  it "should have good defaults" do
    client, out_filename, opts = RbInvoice::parse_command_line(%w{--spreadsheet=foo my-client outfile})
    client.should == 'my-client'
    out_filename.should == 'outfile'

    opts[:no_rcfile].should == false
    opts[:rcfile].should == "#{@tmpdir}/.rbinvoicerc"
    opts[:no_data_dir].should == false
    opts[:data_dir].should == "#{@tmpdir}/.rbinvoice"
    opts[:no_write_invoice_number].should == false
  end

  it "should require an output filename if it can't infer one" do
    lambda {
      RbInvoice::parse_command_line(%w{--spreadsheet=foo my-client})
    }.should raise_error SystemExit
  end

  it "should require a spreadsheet URL if it can't find one in .rbinvoicerc" do
    lambda {
      RbInvoice::parse_command_line(%w{my-client outfile})
    }.should raise_error SystemExit
  end

  it "should use the spreadsheet URL from .rbinvoicerc" do
    File.open("#{@tmpdir}/.rbinvoicerc", 'w') { |f| f.write("spreadsheet: http://foo") }
      client, out_filename, opts = RbInvoice::parse_command_line(%w{my-client outfile})
      opts[:spreadsheet].should == 'http://foo'
  end

end
