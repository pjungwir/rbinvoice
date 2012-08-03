require 'trollop'
require 'roo'
# require 'prawn'

require 'rbinvoice/options'
require 'roo'

module RbInvoice

  COL_DATE       = 'B'
  COL_CLIENT     = 'C'
  COL_TASK       = 'D'
  COL_START_TIME = 'E'
  COL_END_TIME   = 'F'
  COL_TOTAL_TIME = 'G'

  def self.parse_date(str)
    Date.strptime(str, "%m/%d/%Y")
  end

  def self.write_invoice(client, start_date, end_date, filename, opts)
    if start_date and end_date
      tasks = hourly_breakdown(client, start_date, end_date, opts)
    else
      # TODO: Write all the outstanding spreadsheets
    end
  end

  def self.hourly_breakdown(client, start_date, end_date, opts)
    hours = group_by_task(select_date_range(start_date, end_date, read_all_hours(client, opts)))
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

    client = client.downcase.gsub(' ', '')
    return 3.upto(ss.last_row).select { |row|
      (ss.cell(row, COL_CLIENT) || '').downcase.gsub(' ', '') == client
    }.map { |row|
      [ss.cell(row, COL_DATE), ss.cell(row, COL_TASK), ss.cell(row, COL_TOTAL_TIME)]
    }
  end

  def self.select_date_range(start_date, end_date, hours)
    hours.select do |row|
      # puts "#{row[0].class}: #{row.join("\t")}"
      # Sometimes we get a String, sometimes a Date,
      # and changing the cell's format in the spreadsheet
      # doesn't have any effect. So do our best to support both:
      d = row[0].class == String ? parse_date(row[0]) : row[0]
      start_date <= d and d <= end_date
    end
  end
  
  def self.group_by_task(rows)
    rows.group_by{|r| r[1]}
  end

end
