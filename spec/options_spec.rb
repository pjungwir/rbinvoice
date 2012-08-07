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

  it "should compute the first day of the month" do
    RbInvoice::Options::first_day_of_the_month(Date.new(2011, 3, 5)).should == Date.new(2011, 3,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2011, 3,31)).should == Date.new(2011, 3,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2011, 3, 1)).should == Date.new(2011, 3,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2011, 2,28)).should == Date.new(2011, 2,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2012, 2,29)).should == Date.new(2012, 2,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2012, 1, 5)).should == Date.new(2012, 1,1)
    RbInvoice::Options::first_day_of_the_month(Date.new(2011,12, 5)).should == Date.new(2011,12,1)
  end

  it "should compute the last day of the month" do
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 3, 5)).should == Date.new(2011, 3,31)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 3,31)).should == Date.new(2011, 3,31)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 3, 1)).should == Date.new(2011, 3,31)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 4, 8)).should == Date.new(2011, 4,30)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 2,28)).should == Date.new(2011, 2,28)
    RbInvoice::Options::last_day_of_the_month(Date.new(2012, 2,29)).should == Date.new(2012, 2,29)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011, 2,19)).should == Date.new(2011, 2,28)
    RbInvoice::Options::last_day_of_the_month(Date.new(2012, 2,19)).should == Date.new(2012, 2,29)
    RbInvoice::Options::last_day_of_the_month(Date.new(2012, 1, 5)).should == Date.new(2012, 1,31)
    RbInvoice::Options::last_day_of_the_month(Date.new(2011,12, 5)).should == Date.new(2011,12,31)
  end

  it "should compute the semimonth end date" do
    RbInvoice::Options::semimonth_end(Date.new(2011, 3, 5)).should == Date.new(2011, 3,15)
    RbInvoice::Options::semimonth_end(Date.new(2011, 3,21)).should == Date.new(2011, 3,31)
    RbInvoice::Options::semimonth_end(Date.new(2011, 3,31)).should == Date.new(2011, 3,31)
    RbInvoice::Options::semimonth_end(Date.new(2011, 3, 1)).should == Date.new(2011, 3,15)
    RbInvoice::Options::semimonth_end(Date.new(2011, 4, 8)).should == Date.new(2011, 4,15)
    RbInvoice::Options::semimonth_end(Date.new(2011, 2,28)).should == Date.new(2011, 2,28)
    RbInvoice::Options::semimonth_end(Date.new(2012, 2,28)).should == Date.new(2012, 2,29)
    RbInvoice::Options::semimonth_end(Date.new(2012, 2,29)).should == Date.new(2012, 2,29)
    RbInvoice::Options::semimonth_end(Date.new(2011, 2,19)).should == Date.new(2011, 2,28)
    RbInvoice::Options::semimonth_end(Date.new(2012, 2,19)).should == Date.new(2012, 2,29)
    RbInvoice::Options::semimonth_end(Date.new(2012, 1, 5)).should == Date.new(2012, 1,15)
    RbInvoice::Options::semimonth_end(Date.new(2011,12, 1)).should == Date.new(2011,12,15)
    RbInvoice::Options::semimonth_end(Date.new(2011,12, 5)).should == Date.new(2011,12,15)
    RbInvoice::Options::semimonth_end(Date.new(2011,12,15)).should == Date.new(2011,12,15)
    RbInvoice::Options::semimonth_end(Date.new(2011,12,25)).should == Date.new(2011,12,31)
  end

  it "should compute the semimonth start date" do
    RbInvoice::Options::semimonth_start(Date.new(2011, 3, 5)).should == Date.new(2011, 3, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011, 3,21)).should == Date.new(2011, 3,15)
    RbInvoice::Options::semimonth_start(Date.new(2011, 3,31)).should == Date.new(2011, 3,15)
    RbInvoice::Options::semimonth_start(Date.new(2011, 3, 1)).should == Date.new(2011, 3, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011, 4, 8)).should == Date.new(2011, 4, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011, 2,28)).should == Date.new(2011, 2,15)
    RbInvoice::Options::semimonth_start(Date.new(2012, 2,28)).should == Date.new(2012, 2,15)
    RbInvoice::Options::semimonth_start(Date.new(2012, 2,29)).should == Date.new(2012, 2,15)
    RbInvoice::Options::semimonth_start(Date.new(2011, 2,19)).should == Date.new(2011, 2,15)
    RbInvoice::Options::semimonth_start(Date.new(2012, 2,19)).should == Date.new(2012, 2,15)
    RbInvoice::Options::semimonth_start(Date.new(2012, 1, 5)).should == Date.new(2012, 1, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011,12, 1)).should == Date.new(2011,12, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011,12, 5)).should == Date.new(2011,12, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011,12,15)).should == Date.new(2011,12, 1)
    RbInvoice::Options::semimonth_start(Date.new(2011,12,25)).should == Date.new(2011,12,15)
  end

  it "should compute the previous semimonth" do
  end

  it "should have good defaults" do
    ret = RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})
    (client, start_date, end_date, out_filename, opts) = RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})
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
      RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo my-client})
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
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=1041 my-client outfile})
    opts[:invoice_number].should == 1041
  end

  it "should use the next invoice number" do
    File.open("#{@tmpdir}/.rbinvoice", 'w') { |f| f.write("last_invoice: 1040") }
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo my-client outfile})
    opts[:invoice_number].should == 1041
  end

  it "should infer output filename from invoice number and client" do
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=1041 my-client})
    opts[:out_filename].should == './invoice-1041-my-client.pdf'
  end

  it "should use the spreadsheet URL from --spreadsheet" do
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--spreadsheet=foo --invoice-number=5 my-client outfile})
    opts[:spreadsheet].should == 'foo'

    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{-u foo --invoice-number=5 my-client outfile})
    opts[:spreadsheet].should == 'foo'
  end

  it "should use the spreadsheet URL from .rbinvoicerc" do
    File.open("#{@tmpdir}/.rbinvoicerc", 'w') { |f| f.write("spreadsheet: http://foo") }
    client, start_date, end_date, out_filename, opts = *RbInvoice::Options::parse_command_line(%w{--invoice-number=1040 my-client outfile})
    opts[:spreadsheet].should == 'http://foo'
  end

end
