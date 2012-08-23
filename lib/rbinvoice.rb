require 'date'
require 'bigdecimal'
require 'trollop'
# require 'prawn'

require 'rbinvoice/options'
require 'roo'
require 'liquid'

module RbInvoice

  COL_DATE       = 'B'
  COL_CLIENT     = 'C'
  COL_TASK       = 'D'
  COL_START_TIME = 'E'
  COL_END_TIME   = 'F'
  COL_TOTAL_TIME = 'G'

  # TODO:
  #   - Figure out the next invoice_number.
  #   - Record the invoice & the new invoice_number.
  #   - Default dir for the tex & pdf files.

  def self.parse_date(str)
    return str if str.class == Date
    Date.strptime(str, "%m/%d/%Y")
  end

  def self.earliest_task_date(hours)
    row = hours.sort_by { |row| parse_date(row[0]) }.first
    row ? row[0] : nil
  end

  def self.write_invoices(client, start_date, end_date, filename, opts)
    if start_date and end_date
      tasks = hourly_breakdown(client, start_date, end_date, opts)
      make_pdf(tasks, start_date, end_date, filename, opts)
    else
      # Write all the outstanding spreadsheets
      freq = RbInvoice::Options::frequency_for_client(opts[:data], client)
      last_invoice = RbInvoice::Options::last_invoice_for_client(opts[:data], client)
      hours = read_all_hours(client, opts)
      earliest_date = if last_invoice
                     last_invoice[:end_date] + 1
                   else
                     parse_date(earliest_task_date)
                   end
      start_date, end_date = RbInvoice::Options::find_invoice_bounds(earliest_date, freq)
      tasks = hourly_breakdown(client, start_date, end_date, opts)
      while tasks.size > 0
        filename = RbInvoice::Options::default_out_filename(opts)
        make_pdf(tasks, start_date, end_date, filename, opts)
        start_date, end_date = RbInvoice::Options::find_invoice_bounds(end_date + 1, freq)
        tasks = hourly_breakdown(client, start_date, end_date, opts)
        opts[:invoice_number] += 1
      end
    end
  end

  def self.make_pdf(tasks, start_date, end_date, filename, opts)
    write_latex(tasks, end_date, filename, opts)
    system("cd \"#{File.dirname(filename)}\" && pdflatex \"#{File.basename(filename, '.pdf')}\"")
    RbInvoice::Options::add_invoice_to_data(tasks, start_date, end_date, filename, opts) unless opts[:no_data_file]
  end

  def self.escape_for_latex(str)
    str.gsub('&', '\\\\&').   # tricky b/c '\&' has special meaning to gsub.
      gsub('"', '\texttt{"}').
      gsub('$', '\$').
      gsub('+', '$+$')
  end

  def self.write_latex(tasks, invoice_date, filename, opts)
    template = File.open(opts[:template]) { |f| f.read }
    rate = opts[:rate]    # TODO: Support per-task rates
    items = tasks.map{|task, details|
      task_total_hours = details.inject(0) {|t, row| t + row[2]}
      {
        'name' => escape_for_latex(task),
        'duration_decimal' => task_total_hours,
        'duration' => decimal_to_interval(task_total_hours),
        'price_decimal' => task_total_hours * rate,
        'price' => "%0.02f" % (task_total_hours * rate)
      }
    }


    args = Hash[
      {
        invoice_number: opts[:invoice_number],
        invoice_date: invoice_date.strftime("%d %B %Y"),
        line_items: items,
        total_duration: decimal_to_interval(items.inject(0) {|t, item| t + item['duration_decimal']}),
        total_price: "%0.02f" % items.inject(0) {|t, item| t + item['price_decimal']},
      }.map{|k, v| [k.to_s, v]}
    ]
    latex = Liquid::Template.parse(template).render args
    File.open("#{filename.gsub(/\.pdf$/, '')}.tex", 'w') { |f| f.write(latex) }
  end

  def self.hourly_breakdown(client, start_date, end_date, opts)
    hours = group_by_task(select_date_range(start_date, end_date, read_all_hours(client, opts)))
  end

  def self.open_worksheet(spreadsheet, username, password)
    g = Google.new(spreadsheet, username, password)
    g.date_format = '%m/%d/%Y'
    g.default_sheet = g.sheets.first
    return g
  end

  def self.to_client_key(client)
    client.downcase.gsub(' ', '')
  end

  def self.read_all_hours(client, opts)
    ss = nil
    begin
      ss = open_worksheet(opts[:spreadsheet], opts[:spreadsheet_user], opts[:spreadsheet_password])
    rescue Exception => e
      $stderr.puts "rbinvoice: Failed to open spreadsheet #{opts[:spreadsheet]}: #{$!}"
      exit 1
    end

    client = to_client_key(client)
    return 3.upto(ss.last_row).select { |row|
      to_client_key(ss.cell(row, COL_CLIENT) || '') == client
    }.map { |row|
      raise "Invalid task times: #{ss.cell(row, COL_START_TIME)}-#{ss.cell(row, COL_END_TIME)}" if ss.cell(row, COL_START_TIME) && ss.cell(row, COL_END_TIME) && ss.cell(row, COL_TOTAL_TIME) == '0:00:00'
      [ss.cell(row, COL_DATE), ss.cell(row, COL_TASK), interval_to_decimal(ss.cell(row, COL_TOTAL_TIME))]
    }
  end

  def self.interval_to_decimal(time)
    return nil unless time
    d = Date._strptime(time, "%H:%M")
    BigDecimal.new(d[:hour] * 60 + d[:min]) / 60
  end

  def self.decimal_to_interval(time)
    "%d:%02d" % [time.to_i, (60*time) % 60]
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
