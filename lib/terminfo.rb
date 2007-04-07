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
  def initialize(term=nil, io=STDERR)
    setupterm(term, io.fileno)
    @io = io
  end

  def control_string(*args)
    afflines = 1
    raise ArgumentError, "capname requried" if args.empty?
    afflines = args.shift.to_i if args.first.respond_to?(:to_int)
    raise ArgumentError, "capname not given" if !args.first.respond_to?(:to_str)
    capname = args.shift.to_str 
    self.tputs(self.tparm(self.tigetstr(capname), *args), afflines)
  end

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
      begin
        Thread.current[:TermInfo_Flush_level] = (oldlevel || 0) + 1
        yield
      ensure
        Thread.current[:TermInfo_Flush_level] = oldlevel
      end
    end
    @io.flush if oldlevel == nil
    nil
  end

  def winsize
    TermInfo.tiocgwinsz(@io)
  end
end
