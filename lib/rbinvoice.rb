require 'trollop'
require 'roo'
# require 'prawn'

require 'rbinvoice/options'
require 'roo'

module RbInvoice

  def self.write_invoice(client, filename, opts)
    tasks = hourly_breakdown(client, opts)
  end

  def self.hourly_breakdown(client, opts)
    hours = read_all_hours(client, opts)
  end

  def self.open_worksheet(spreadsheet, username, password)
    g = Google.new(spreadsheet, username, password)
    g.default_sheet = g.sheets.first
    return g
  end

  def self.read_all_hours(client, opts)
    ss = nil
    begin
      ss = open_worksheet(opts[:spreadsheet], opts[:spreadsheet_user], opts[:spreadsheet_password])
    rescue Exception => e
      $stderr.puts "rbinvoice: Failed to open spreadsheet #{opts[:spreadsheet]}: #{$!}"
      exit 1
    end

    3.upto(ss.last_row) do |row|
      puts "#{ss.cell(row, 'C')}: #{ss.cell(row, 'G')}"
    end

  end

end
