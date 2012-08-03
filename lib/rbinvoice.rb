require 'trollop'
require 'roo'
# require 'prawn'

require 'rbinvoice/options'
require 'roo'

module RbInvoice

  def self.write_invoice(client, filename, opts)
  end

  def self.hourly_breakdown(client, opts)
    hours = read_all_hours(client, opts)
  end

  def self.open_worksheet(spreadsheet)
    Spreadsheet.open(spreadsheet).worksheet(0)
  end

  def self.read_all_hours(client, opts)
    ss = nil
    begin
      ss = open_worksheet(opts[:spreadsheet])
    rescue Exception => e
      $stderr.puts "rbinvoice: Failed to open spreadsheet #{opts[:spreadsheet]}: $!"
      exit 1
    end
  end

end
