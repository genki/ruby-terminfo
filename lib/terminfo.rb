# terminfo.rb - a part of a Ruby binding for terminfo library.
#
# Copyright (C) 2007 Tanaka Akira. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#  3. The name of the author may not be used to endorse or promote
#     products derived from this software without specific prior
#     written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'terminfo.so'

class TermInfo
  def TermInfo.default_object
    unless defined? @default_terminfo
      io = open("/dev/tty", "r+")
      io.sync = true
      @default_terminfo = TermInfo.new(ENV['TERM'], io)
    end
    @default_terminfo
  end

  def TermInfo.control_string(*args) default_object.control_string(*args) end
  def TermInfo.control(*args) default_object.control(*args) end
  def TermInfo.write(str) default_object.write(str) end
  def TermInfo.flush(&block) default_object.flush(&block) end
  def TermInfo.screen_size() default_object.screen_size() end
  def TermInfo.screen_lines() default_object.screen_lines() end
  def TermInfo.screen_height() default_object.screen_height() end
  def TermInfo.screen_columns() default_object.screen_columns() end
  def TermInfo.screen_width() default_object.screen_width() end
  def TermInfo.io() default_object.io() end

  def initialize(term=ENV['TERM'], io=STDERR)
    setupterm(term, io.fileno)
    @term = term
    @io = io
  end
  attr_reader :io

  def inspect
    "\#<#{self.class}:#{@term}>"
  end

  # TermInfo#control_string return a string to control terminal.
  #
  #   TermInfo#control_string([afflines,] capname, p1, p2, ...)
  #
  # capname is a terminfo string capability such as "cuu", "el".
  #
  # p1, p2, ... are parameters for the capability.
  #
  # afflines is a number of lines affected. (used for determining padding length)
  def control_string(*args)
    afflines = 1
    raise ArgumentError, "capname requried" if args.empty?
    afflines = args.shift.to_i if args.first.respond_to?(:to_int)
    raise ArgumentError, "capname not given" if !args.first.respond_to?(:to_str)
    capname = args.shift.to_str 
    self.tputs(self.tparm(self.tigetstr(capname), *args), afflines)
  end

  # TermInfo#control controls a terminal. 
  #
  # It prints the result of control_string to io specified at initialization.
  def control(*args)
    @io.write(self.control_string(*args))
    nil
  end

  def write(str)
    @io.write(str)
  end

  def flush
    oldlevel = nil
    if block_given?
      oldlevel = Thread.current[:TermInfo_Flush_level]
      oldsync = @io.sync
      begin
        Thread.current[:TermInfo_Flush_level] = (oldlevel || 0) + 1
        @io.sync = false
        yield
      ensure
        Thread.current[:TermInfo_Flush_level] = oldlevel
        @io.sync = oldsync
      end
    end
    @io.flush if oldlevel == nil
    nil
  end

  # returns terminal screen size in a two element array: [lines, columns].
  def screen_size
    begin
      size = TermInfo.tiocgwinsz(@io)
    rescue NotImplementedError
      size = [0,0]
    end
    if size[0] == 0
      size[0] = ENV.include?('LINES') ? ENV['LINES'].to_i : self.tigetnum("lines")
    end
    if size[1] == 0
      size[1] = ENV.include?('COLUMNS') ? ENV['COLUMNS'].to_i : self.tigetnum("cols")
    end
    size
  end

  # returns terminal screen height.
  def screen_lines
    self.screen_size[0]
  end
  alias screen_height screen_lines

  # returns terminal screen width.
  def screen_columns
    self.screen_size[1]
  end
  alias screen_width screen_columns
end
