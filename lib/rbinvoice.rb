require 'trollop'
# require 'roo'
# require 'prawn'

module RbInvoice

  DEFAULT_RC_FILE = File.join(ENV['HOME'] || '.', '.rbinvoicerc')
  DEFAULT_DATA_DIR  = File.join(ENV['HOME'] || '.', '.rbinvoice')

  def self.write_dot_rbinvoice_dir(dir)
  end

  def self.dot_rbinvoice_dir(opts)
  end

  def self.read_data_dir(opts)
    if File.exist?(opts[:data_dir])
      return parse_data_dir(File.read(opts[:data_dir]), opts)
    else
      return {}
    end
  end

  def self.parse_data_dir(text, opts)
    if text
      # Expected keys include:
      #   max_invoice_number
      return YAML::load(text)
    else
      return nil
    end
  end

  def self.write_invoice
  end

  def self.read_rc_file(opts)
    Trollop::die :rcfile, "doesn't exist" if opts[:rcfile] and not File.exist?(opts[:rcfile])

    # Don't apply the default until now
    # so we know if the user requested one specifically or not:
    opts[:rcfile] ||= DEFAULT_RC_FILE
    parse_rc_file(File.read(opts[:rcfile])) if File.exist?(opts[:rcfile])
  end

  def self.parse_rc_file(text, opts)
  end

  def self.default_out_dir(opts)
  end

  # Looks in ~/.rbinvoice 
  def self.default_out_filename(opts)

  end

  def self.parse_command_line(argv)
    opts = Trollop::options(argv) do
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
      opt :rcfile, "Use an rc file other than ~/.rbinvoicerc"
      opt :no_rcfile, "Don't read an rc file", :default => false
      opt :data_dir, "Use a data dir other than ~/.rbinvoice", :default => DEFAULT_DATA_DIR
      opt :no_data_dir, "Don't read or write to a data dir", :default => false
      opt :invoice_number, "Use a specific invoice number", :type => :int, :short => '-n'
      opt :no_write_invoice_number, "Record the invoice number", :default => false
      
    end
    Trollop::die :client, "must be given" unless argv.size > 0
    opts[:client] = argv.shift

    read_rc_file(opts) unless opts[:no_rcfile]
    read_data_dir(opts) unless opts[:no_data_dir]

    opts[:out_filename] = argv.shift
    if not opts[:out_filename]
      opts[:out_filename] = default_out_filename(opts)
      opts[:used_default_out_filename] = true     # TODO if this is set and not quiet, then print the name of the file we wrote to: "Wrote invoice to #{out_filename}"
    end
    Trollop::die :output_filename, "must be given" unless opts[:out_filename]

    return opts[:client], opts[:out_filename], opts
  end

end
