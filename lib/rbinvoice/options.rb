require 'yaml'
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

    def self.default_template_filename
      File.join(File.dirname(__FILE__), '..', '..', 'templates', 'invoice.tex.liquid')
    end

    def self.write_data_file(opts)
      # Add the new invoice to the list of client invoices.
      File.open(opts[:data_file], 'w') { |f| f.puts YAML::dump(RbInvoice::Util::stringify_hash(opts[:data])) }
    end

    def self.read_data_file(opts)
      if File.exist?(opts[:data_file])
        ret = parse_data_file(File.read(opts[:data_file]), opts)
        client = data_for_client(ret, opts[:client])
        opts[:rate] = client[:rate] if client
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
      %w{spreadsheet spreadsheet_user spreadsheet_password out_directory}.each do |key|
        key = key.to_sym
        opts[key] ||= rc[key]
      end
      return opts
    end

    # TODO: Allow per-client settings to override the global setting
    def self.default_out_directory(opts)
      opts[:out_directory] || '.'
    end

    # Looks in ~/.rbinvoice 
    def self.default_out_filename(opts)
      if opts[:client] and opts[:invoice_number]
        File.join(default_out_directory(opts), "invoice-#{opts[:invoice_number]}-#{opts[:client]}.pdf")
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
        Date.new(d.year, d.month, 16)
      end
    end

    def self.week_start(d)
      # Assumes the week starts on a Sunday:
      d - d.wday
    end

    def self.week_end(d)
      week_start(d) + 7
    end

    # second_half_of_biweek - indicates that `d` is from the second half of the biweek.
    # If false (the default), we assume `d` is from the first half.
    def self.find_invoice_bounds(d, freq, second_half_of_biweek=false)
      case freq.to_sym
      when :weekly
        return week_start(d), week_end(d)
      when :biweekly
        if second_half_of_biweek
          return week_start(d) - 7, week_end(d)
        else
          return week_start(d), week_end(d) + 7
        end
      when :semimonthly
        return semimonth_start(d), semimonth_end(d)
      when :monthly
        return first_day_of_the_month(d), last_day_of_the_month(d)
      else
        raise "Unknown frequency: #{freq}"
      end
    end

    def self.add_new_client_data(client, data)
      h = {
        'name' => client,
        'key' => client,
        'invoices' => []
      }
      (data[:clients] ||= []) << h
      return h
    end

    def self.add_invoice_to_data(tasks, start_date, end_date, filename, opts)
      data = opts[:data]
      client = data_for_client(data, opts[:client]) || add_new_client_data(opts[:client], data)
      (client[:invoices] ||= []) << {
        'id' => opts[:invoice_number],
        'start_date' => start_date,
        'end_date' => end_date,
        'filename' => filename
      }
      if not data[:last_invoice] or opts[:invoice_number] > data[:last_invoice]
        data[:last_invoice] = opts[:invoice_number]
      end
      write_data_file(opts)
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

    def self.dba_for_client(data, opts, client)
      key_for_client(data, client, :dba) || opts[:dba] || 'Illuminated Computing Inc.'
    end

    def self.payment_due_for_client(data, opts, client)
      key_for_client(data, client, :payment_due) || opts[:payment_due] || 'upon receipt'
    end

    def self.full_name_for_client(data, opts, client)
      key_for_client(data, client, :full_name)
    end

    def self.address_for_client(data, opts, client)
      key_for_client(data, client, :address)
    end

    def self.description_for_client(data, opts, client)
      key_for_client(data, client, :description)
    end

    def self.parse_command_line(argv)
      opts = Trollop::options(argv) do
        version "rbinvoice 0.1.0 (c) 2012 Paul A. Jungwirth"
        banner <<-EOH
          USAGE: rbinvoice [options] <client> [filename]
        EOH
        opt :help, "Show a help message"

        opt :rcfile, "Use an rc file other than ~/.rbinvoicerc", :short => '-r'
        opt :no_rcfile, "Don't read an rc file", :default => false, :short => '-R'

        opt :data_file, "Use a data file other than ~/.rbinvoice", :default => RbInvoice::Options.default_data_file, :short => '-d'
        opt :no_data_file, "Don't read or write to a data file", :default => false, :short => '-D'

        opt :invoice_number, "Use a specific invoice number", :type => :int, :short => '-n'
        opt :no_write_invoice_number, "Record the invoice number", :default => false, :short => '-N'

        opt :spreadsheet, "Read the given spreadsheet URL", :type => :string, :short => '-u'
        opt :start_date, "Date to begin the invoice (yyyy-mm-dd)", :type => :string
        opt :end_date, "Date to end the invoice (yyyy-mm-dd)", :type => :string

        opt :template, "Use the given liquid template", :type => :string, :default => RbInvoice::Options::default_template_filename
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

      opts[:dba] = dba_for_client(opts[:data], opts, opts[:client])
      opts[:payment_due] = payment_due_for_client(opts[:data], opts, opts[:client])
      # Read the list of past invoices.
      # If there are none, assume there is only one invoice to do.

      jobs = []

      last_invoice = last_invoice_for_client(opts[:data], opts[:client])
      if opts[:end_date] and opts[:start_date]
        # just do it, regardless of frequency.
      elsif opts[:end_date] or opts[:start_date]
        freq = frequency_for_client(opts[:data], opts[:client])
        if freq
          opts[:start_date], opts[:end_date] = find_invoice_bounds(opts[:start_date] || opts[:end_date], freq, !!opts[:end_date])
        else
          Trollop::die "can't determine invoice range without frequency"
        end
      else
        # Do all pending invoices (leave start_date and end_date nil).
      end

      # return jobs

      return opts[:client], opts[:start_date], opts[:end_date], opts[:out_filename], opts
    end

  end
end
