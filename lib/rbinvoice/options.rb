require 'trollop'

module RbInvoice
  module Options

    def self.symbolize_array(arr)
      arr.map{|x|
        case x
        when Hash; symbolize_hash(x)
        when Array; symbolize_array(x)
        else x
        end
      }
    end

    def self.symbolize_hash(h)
      h.each_with_object({}) {|(k,v), h|
        h[k.to_sym] = case v
                      when Hash; symbolize_hash(v)
                      when Array; symbolize_array(v)
                      else; v
                      end
      }
    end

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
    def self.default_data_dir
      File.join(ENV['HOME'] || '.', '.rbinvoice')
    end

    def self.write_dot_rbinvoice_dir(dir)
    end

    def self.dot_rbinvoice_dir(opts)
    end

    def self.read_with_yaml(text)
      symbolize_hash(YAML::load(text) || {})
    end

    def self.read_data_dir(opts)
      if File.exist?(opts[:data_dir])
        ret = parse_data_dir(File.read(opts[:data_dir]), opts)
        client = ret[:clients].select{|x| x[:key] == opts[:client]}.first
        ret[:rate] = client[:rate] if client
        return ret
      else
        return {}
      end
    end

    def self.parse_data_dir(text, opts)
      # Expected keys include:
      #   max_invoice_number
      text ? read_with_yaml(text) : {}
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
      rc = (text ? read_with_yaml(text) : {})
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
      if opts[:client] and opts[:data][:last_invoice]
        "invoice-#{opts[:data][:last_invoice].to_i + 1}-#{opts[:client]}.pdf"
      else
        nil
      end
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
              --data-dir=<dirname>                     Use a data dir other than ~/.rbinvoice.
              --no-data-dir                            Don't read or write to a data dir.
              --invoice-number=<n>                     Use a specific invoice number.
              --no-write-invoice-number                Record the invoice number.
              --spreadsheet=<url>                      Pull data from <url>.
        EOH
        opt :help, "Show a help message"

        opt :rcfile, "Use an rc file other than ~/.rbinvoicerc", :short => '-r'
        opt :no_rcfile, "Don't read an rc file", :default => false, :short => '-R'

        opt :data_dir, "Use a data dir other than ~/.rbinvoice", :default => RbInvoice::Options.default_data_dir, :short => '-d'
        opt :no_data_dir, "Don't read or write to a data dir", :default => false, :short => '-D'

        opt :invoice_number, "Use a specific invoice number", :type => :int, :short => '-n'
        opt :no_write_invoice_number, "Record the invoice number", :default => false, :short => '-N'

        opt :spreadsheet, "Read the given spreadsheet URL", :type => :string, :short => '-s'
        opt :start_date, "Date to begin the invoice (m/d/yyyy)", :type => :string
        opt :end_date, "Date to end the invoice (m/d/yyyy)", :type => :string
      end
      Trollop::die "client must be given" unless argv.size > 0
      opts[:client] = argv.shift

      read_rc_file(opts) unless opts[:no_rcfile]
      opts[:data] = opts[:no_data_dir] ? {} : read_data_dir(opts)

      Trollop::die "can't determine hourly spreadsheet" unless opts[:spreadsheet]

      opts[:out_filename] = argv.shift
      if not opts[:out_filename]
        opts[:out_filename] = default_out_filename(opts)
        opts[:used_default_out_filename] = true     # TODO if this is set and not quiet, then print the name of the file we wrote to: "Wrote invoice to #{out_filename}"
      end
      Trollop::die "can't infer output filename; please provide one" unless opts[:out_filename]

      opts[:start_date] = '7/15/2012'
      opts[:end_date] = '7/31/2012'
      opts[:start_date] = RbInvoice::parse_date(opts[:start_date])
      opts[:end_date] = RbInvoice::parse_date(opts[:end_date])

      return opts[:client], opts[:start_date], opts[:end_date], opts[:out_filename], opts
    end

  end
end
