# ruby-terminfo - terminfo bindings for Ruby

ruby-terminfo provides terminfo bindings for Ruby

[![Gem Version](https://badge.fury.io/rb/ruby-terminfo.svg)](https://badge.fury.io/rb/ruby-terminfo)

## Author

Tanaka Akira <akr@fsij.org>

## Home Page

http://www.a-k-r.org/ruby-terminfo/

## Features

* Easy to use methods
  * `control` (combination of `tigetstr`/`tparm`/`tputs`)
* Low-level terminfo bindings
  * `setupterm`
  * `tigetflag`
  * `tigetnum`
  * `tigetstr`
  * `tparm`
  * `tputs`
* TIOCGWINSZ/TIOCSWINSZ ioctl for screen size 
* `ctermid` to avoid hardcoding /dev/tty
* `wcswidth` to measure a string width in number of columns

## Usage

### Easy to use methods
```ruby
require 'terminfo'

TermInfo.control("cuf", 7)    # cursor forward 7 columns
p TermInfo.screen_size        # use TIOCGWINSZ, LINES/COLUMNS env. or terminfo lines#/cols#
```

### Low level methods
```ruby
require 'terminfo'

t = TermInfo.new(ENV["TERM"], File.open(TermInfo.ctermid, "r+"))
print t.tputs(t.tparm(t.tigetstr("cuf"), 7), 1)  # cursor forward 7 columns
p TermInfo.tiocgwinsz(STDOUT)                    # use TIOCGWINSZ
```

## Requirements

* Ruby : http://www.ruby-lang.org/

## Download

* Latest release: http://www.a-k-r.org/ruby-terminfo/ruby-terminfo-0.2.tar.gz

* Development version: http://github.com/akr/ruby-terminfo

## Install

```shell
ruby extconf.rb
make
make install
```

## Reference Manual

See rdoc/TermInfo.html or
http://www.a-k-r.org/ruby-terminfo/rdoc/TermInfo.html

## License


Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

(1) Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
(2) Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
(3) The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.

(The modified BSD licence)
