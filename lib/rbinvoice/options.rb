require 'trollop'
require 'rbinvoice/util'

module RbInvoice
  module Options

    # This is a method rather than a constant
    # so that we don't evaulate ENV['HOME']
    # until it's called. That makes it possible
    # for tests to set ENV['HOME'] before running the code.
    def self.default_rc_file
      File.join(ENV['HOME'] || '.', '.rbinvoicerc')
    end

    # This is a method rather than a constant
    # so that we don't evaulate ENV['HOME']
    # until it's called. That makes it possible
    # for tests to set ENV['HOME'] before running the code.
    def self.default_data_file
      File.join(ENV['HOME'] || '.', '.rbinvoice')
    end

    def self.write_data_file(opts)
      # Add the new invoice to the list of client invoices.
      File.open(opts[:data_file], 'w') { |f| f.puts YAML::dump(opts[:data]) }
    end

    def self.read_data_file(opts)
      if File.exist?(opts[:data_file])
        ret = parse_data_file(File.read(opts[:data_file]), opts)
        client = all_clients(ret).select{|x| x[:key] == opts[:client]}.first
        if client
          client = client.select{|x| x[:key] == opts[:client]}.first
          ret[:rate] = client[:rate] if client
        end
        return ret
      else
        return {}
      end
    end

    def self.parse_data_file(text, opts)
      text ? RbInvoice::Util::read_with_yaml(text) : {}
    end

    def self.read_rc_file(opts)
      Trollop::die :rcfile, "doesn't exist" if opts[:rcfile] and not File.exist?(opts[:rcfile])

      # Don't apply the default until now
      # so we know if the user requested one specifically or not:
      opts[:rcfile] ||= default_rc_file

      if File.exist?(opts[:rcfile])
        return parse_rc_file(File.read(opts[:rcfile]), opts)
      else
        return opts
      end
    end

    def self.parse_rc_file(text, opts)
      rc = (text ? RbInvoice::Util::read_with_yaml(text) : {})
      %w{spreadsheet spreadsheet_user spreadsheet_password}.each do |key|
        key = key.to_sym
        opts[key] ||= rc[key]
      end
      return opts
    end

    def self.default_out_dir(opts)
    end

    # Looks in ~/.rbinvoice 
    def self.default_out_filename(opts)
      if opts[:client] and opts[:invoice_number]
        "invoice-#{opts[:invoice_number]}-#{opts[:client]}.pdf"
      else
        nil
      end
    end

    def self.first_day_of_the_month(d)
      Date.new(d.year, d.month, 1)
    end

    def self.last_day_of_the_month(d)
      n = d.next_month
      Date.new(d.year, d.month, (Date.new(n.year, n.month, 1) - 1).day)
    end

    def self.semimonth_end(d)
      if d.day <= 15
        Date.new(d.year, d.month, 15)
      else
        Date.new(d.year, d.month, last_day_of_the_month(d).day)
      end
    end

    def self.semimonth_start(d)
      if d.day <= 15
        first_day_of_the_month(d)
      else
        Date.new(d.year, d.month, 15)
      end
    end

    def self.find_invoice_bounds(sd, ed, freq)
      case freq.to_sym
      when :weekly
        if sd then ed = sd + 7 else sd = ed - 7 end
      when :biweekly
        if sd then ed = sd + 14 else sd = ed - 14 end
      when :semimonthly
        if sd then ed = semimonth_end(sd) else sd = semimonth_start(ed) end
      when :monthly
        if sd then ed = last_day_of_the_month(sd) else sd = first_day_of_the_month(ed) end
      else
        raise "Unknown frequency: #{freq}"
      end
      return sd, ed
    end

    def self.all_clients(data)
      data[:clients] || []
    end

    def self.last_invoice_number(data)
      data[:last_invoice]
    end

    def self.data_for_client(data, client)
      all_clients(data).select{|x| x[:key] == RbInvoice::to_client_key(client)}.first
    end

    def self.key_for_client(data, client, key)
      d = data_for_client(data, client)
      d = d ? d[key] : nil
    end

    def self.frequncy_for_client(data, client)
      key_for_client(data, client, :frequency)
    end

    def self.invoices_for_client(data, client)
      key_for_client(data, client, :invoices) || []
    end

    def self.last_invoice_for_client(data, client)
      invoices_for_client(data, client).sort_by{|x| x[:end_date]}.last
    end

    def self.frequency_for_client(data, client)
      key_for_client(data, client, :frequency)
    end

    def self.parse_command_line(argv)
      opts = Trollop::options(argv) do
        version "rbinvoice 0.1.0 (c) 2012 Paul A. Jungwirth"
        banner <<-EOH
          USAGE: rbinvoice [options] <client> [filename]
            Options:
              -h, --help                               Print this message.
              --rcfile=<filename>                      Use an rc file other than ~/.rbinvoicerc.
              --no-rcfile                              Don't read an rc file.
              --data-file=<dirname>                    Use a data file other than ~/.rbinvoice.
              --no-data-file                           Don't read or write to a data file.
              --invoice-number=<n>                     Use a specific invoice number.
              --no-write-invoice-number                Don't record the invoice number.
              --spreadsheet=<url>                      Pull data from <url>.
        EOH
        opt :help, "Show a help message"

        opt :rcfile, "Use an rc file other than ~/.rbinvoicerc", :short => '-r'
        opt :no_rcfile, "Don't read an rc file", :default => false, :short => '-R'

        opt :data_file, "Use a data dir other than ~/.rbinvoice", :default => RbInvoice::Options.default_data_file, :short => '-d'
        opt :no_data_file, "Don't read or write to a data file", :default => false, :short => '-D'

        opt :invoice_number, "Use a specific invoice number", :type => :int, :short => '-n'
        opt :no_write_invoice_number, "Record the invoice number", :default => false, :short => '-N'

        opt :spreadsheet, "Read the given spreadsheet URL", :type => :string, :short => '-s'
        opt :start_date, "Date to begin the invoice (yyyy-mm-dd)", :type => :string
        opt :end_date, "Date to end the invoice (yyyy-mm-dd)", :type => :string
      end
      Trollop::die "client must be given" unless argv.size > 0
      opts[:client] = argv.shift

      read_rc_file(opts) unless opts[:no_rcfile]
      opts[:data] = opts[:no_data_file] ? {} : read_data_file(opts)

      if not opts[:invoice_number] and not last_invoice_number(opts[:data])
        Trollop::die "Can't determine invoice number"
      end
      opts[:invoice_number] ||= last_invoice_number(opts[:data]) + 1

      Trollop::die "can't determine hourly spreadsheet" unless opts[:spreadsheet]

      opts[:out_filename] = argv.shift
      if not opts[:out_filename]
        opts[:out_filename] = default_out_filename(opts)
        opts[:used_default_out_filename] = true     # TODO if this is set and not quiet, then print the name of the file we wrote to: "Wrote invoice to #{out_filename}"
      end
      Trollop::die "can't infer output filename; please provide one" unless opts[:out_filename]

      # opts[:start_date] = '2012-07-15'
      # opts[:end_date]   = '2012-07-31'
      opts[:start_date] = Date.strptime(opts[:start_date], "%Y-%m-%d")  if opts[:start_date]
      opts[:end_date]   = Date.strptime(opts[:end_date], "%Y-%m-%d")    if opts[:end_date]

      # Read the list of past invoices.
      # If there are none, assume there is only one invoice to do.

      jobs = []

      last_invoice = last_invoice_for_client(opts[:data], opts[:client])
      if opts[:end_date] and opts[:start_date]
        # just do it, regardless of frequency.
      elsif opts[:end_date] or opts[:start_date]
        freq = frequency_for_client(opts[:data], opts[:client])
        if freq
          opts[:start_date], opts[:end_date] = find_invoice_bounds(opts[:start_date], opts[:end_date], freq)
        else
          Trollop::die "can't determine invoice range without frequency"
        end
      else
        # Do all pending invoices.
      end

      # return jobs

      return [[opts[:client], opts[:start_date], opts[:end_date], opts[:out_filename], opts]]
    end

  end
end
