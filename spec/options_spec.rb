require 'rbinvoice'

describe RbInvoice::Options do

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
    ret = RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})[0]
    (client, start_date, end_date, out_filename, opts) = RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})[0]
    client.should == 'my-client'
    out_filename.should == 'outfile'

    opts[:no_rcfile].should == false
    opts[:rcfile].should == "#{@tmpdir}/.rbinvoicerc"
    opts[:no_data_file].should == false
    opts[:data_file].should == "#{@tmpdir}/.rbinvoice"
    opts[:no_write_invoice_number].should == false
  end

  it "should require an output filename if it can't infer one" do
    lambda {
      RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client})
    }.should raise_error SystemExit
  end

  it "should require a spreadsheet URL if it can't find one in .rbinvoicerc" do
    lambda {
      RbInvoice::Options::parse_command_line(%w{--invoice-number=5 my-client outfile})
    }.should raise_error SystemExit
  end

  it "should require an invoice number if it can't infer one" do
    lambda {
      RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo my-client outfile})
    }.should raise_error SystemExit
  end

  it "should use the given invoice number" do
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=1041 my-client outfile})[0]
    opts[:invoice_number].should == 1041
  end

  it "should use the next invoice number" do
    File.open("#{@tmpdir}/.rbinvoice", 'w') { |f| f.write("last_invoice: 1040") }
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo my-client outfile})[0]
    opts[:invoice_number].should == 1041
  end

  it "should use the spreadsheet URL from --spreadsheet" do
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})[0]
    opts[:spreadsheet].should == 'foo'

    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{-s foo --invoice-number=5 my-client outfile})[0]
    opts[:spreadsheet].should == 'foo'
  end

  it "should use the spreadsheet URL from .rbinvoicerc" do
    File.open("#{@tmpdir}/.rbinvoicerc", 'w') { |f| f.write("spreadsheet: http://foo") }
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--invoice-number=1040 my-client outfile})[0]
    opts[:spreadsheet].should == 'http://foo'
  end

end
