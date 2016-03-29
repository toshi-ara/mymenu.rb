#!/usr/bin/env ruby
# coding: utf-8

# peco binary
PECO = File.expand_path "/usr/bin/peco"

# terminal emulator (xterm/urxvt/mlterm)
XTERM = "mlterm"

USER = ENV['USER']
filename="/home/#{USER}/.mymenu"


require 'tempfile'

class Launcher
  def initialize(filename)
    @filename = filename
    @appfilename = Tempfile.new("tmpnew").path
    @hash = Hash.new
  end

  protected

  def set_hash_and_list
    io1 = File.open(@filename, "r")     # filelist
    io2 = File.open(@appfilename, "w")  # list of application name

    io1.each {|line|
      line.strip!
      line.chomp!
      next if line == "" || (/^#/ =~ line)

      rows = line.split(/,/)
      rows[1] = rows[0] if rows[1].nil?
      @hash.store(rows[0], rows[1])
      io2.puts rows[0]
    }
    io1.close
    io2.close
  end

  def exec_peco
    out = Tempfile.new "peco-out"
    err = Tempfile.new "peco-err"
    system "#{XTERM} -e sh -c '#{PECO} #{@appfilename} > #{out.path} 2> #{err.path}'"

    res = `cat #{out.path}`
    if res != ""
      app = @hash[res.chomp!]
      system("#{app} &")
    end
  end

  public

  def exec_launcher
    self.set_hash_and_list
    self.exec_peco
  end
end

launchar = Launcher.new(filename)
launchar.exec_launcher

