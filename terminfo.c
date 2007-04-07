/* terminfo.c - Ruby binding for terminfo library.

Copyright (C) 2007 Tanaka Akira. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above
    copyright notice, this list of conditions and the following
    disclaimer in the documentation and/or other materials provided
    with the distribution.
 3. The name of the author may not be used to endorse or promote
    products derived from this software without specific prior
    written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "ruby.h"

#include <curses.h>
#include <term.h>

static VALUE cTermInfo;
static VALUE eTermInfoError;

static void
rt_free(void *ptr)
{
  if(ptr != NULL)
    del_curterm(ptr);
}

static VALUE
rt_alloc(VALUE klass)
{
  return Data_Wrap_Struct(klass, NULL, rt_free, 0);
}

static TERMINAL *
check_rt(VALUE self)
{
    Check_Type(self, T_DATA);
    if (RDATA(self)->dfree != rt_free) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected TermInfo)",
                 rb_class2name(CLASS_OF(self)));
    }
    return DATA_PTR(self);
}

static void
setup(VALUE self)
{
  TERMINAL *old;
  TERMINAL *term = check_rt(self);
  if (term == NULL) { rb_raise(eTermInfoError, "not initialized"); }
  if (cur_term == term)
    return;
  old = set_curterm(term);
}

static VALUE
rt_setupterm(VALUE self, VALUE v_term, VALUE v_io)
{
  char *term;
  int fd;
  int err;
  int ret;

  if (v_term == Qnil)
    term = NULL;
  else
    term = StringValueCStr(v_term);
  fd = NUM2INT(v_io);

  ret = setupterm(term, fd, &err);
  if (ret == ERR) {
    if (err == 1) rb_raise(eTermInfoError, "hardcopy terminal");
    else if (err == 0) rb_raise(eTermInfoError, "terminal could not be found");
    else if (err == -1) rb_raise(eTermInfoError, "terminfo database could not be found");
    else rb_raise(eTermInfoError, "unexpected setupterm error");
  }

  DATA_PTR(self) = cur_term;

  return INT2NUM(err);
}

static VALUE
rt_tigetflag(VALUE self, VALUE v_capname)
{
  int ret;
  setup(self);
  ret = tigetflag(StringValueCStr(v_capname));
  if (ret == -1) { rb_raise(eTermInfoError, "not a boolean capability"); }
  return RTEST(ret) ? Qtrue : Qfalse;
}

static VALUE
rt_tigetnum(VALUE self, VALUE v_capname)
{
  int ret;
  setup(self);
  ret = tigetnum(StringValueCStr(v_capname));
  if (ret == -2) { rb_raise(eTermInfoError, "not a numeric capability"); }
  if (ret == -1) { rb_raise(eTermInfoError, "canceled or absent numeric capability"); }
  return INT2NUM(ret);
}

static VALUE
rt_tigetstr(VALUE self, VALUE v_capname)
{
  char *ret;
  setup(self);
  ret = tigetstr(StringValueCStr(v_capname));
  if (ret == (char*)-1) {
    rb_raise(eTermInfoError, "not a string capability");
  }
  if (ret == 0) {
    rb_raise(eTermInfoError, "canceled or absent string capability");
  }
  return rb_str_new2(ret);
}

static VALUE
rt_tparm(int argc, VALUE *argv, VALUE self)
{
  char *capname, *ret;
  setup(self);
  VALUE v_capname, v1, v2, v3, v4, v5, v6, v7, v8, v9;
  long p1, p2, p3, p4, p5, p6, p7, p8, p9;
  setup(self);

  if (rb_scan_args(argc, argv, "19", &v_capname, &v1, &v2, &v3, &v4, &v5, &v6, &v7, &v8, &v9) == 0) {
    rb_raise(rb_eArgError, "capname required");
  }

  capname = StringValueCStr(v_capname);
#define conv(p, v) do { if (v == Qnil) p = 0; else p = NUM2LONG(v); } while(0)
  conv(p1, v1);
  conv(p2, v2);
  conv(p3, v3);
  conv(p4, v4);
  conv(p5, v5);
  conv(p6, v6);
  conv(p7, v7);
  conv(p8, v8);
  conv(p9, v9);

  ret = tparm(capname, p1, p2, p3, p4, p5, p6, p7, p8, p9);

  if (ret == NULL) { rb_raise(eTermInfoError, "tparm failed"); }

  return rb_str_new2(ret);
}

static VALUE putfunc_output; /* xxx: not thread safe */

static int
putfunc(int arg)
{
  char ch = arg;
  rb_str_cat(putfunc_output, &ch, 1);
}

static VALUE
rt_tputs(VALUE self, VALUE v_str, VALUE v_affcnt)
{
  int ret;
  char *str;
  int affcnt;
  VALUE output;

  setup(self);
  str = StringValueCStr(v_str);
  affcnt = NUM2INT(v_affcnt);

  putfunc_output = output = rb_str_new2("");
  ret = tputs(str, affcnt, putfunc);
  putfunc_output = Qnil;

  if (ret == ERR) { rb_raise(eTermInfoError, "tputs failed"); }

  return output;
}

void
Init_terminfo()
{
  putfunc_output = Qnil;
  rb_global_variable(&putfunc_output);

  cTermInfo = rb_define_class("TermInfo", rb_cData);
  eTermInfoError = rb_define_class_under(cTermInfo, "TermInfoError", rb_eRuntimeError);

  rb_define_alloc_func(cTermInfo, rt_alloc);

  rb_define_method(cTermInfo, "setupterm", rt_setupterm, 2);
  rb_define_method(cTermInfo, "tigetflag", rt_tigetflag, 1);
  rb_define_method(cTermInfo, "tigetnum", rt_tigetnum, 1);
  rb_define_method(cTermInfo, "tigetstr", rt_tigetstr, 1);
  rb_define_method(cTermInfo, "tparm", rt_tparm, -1);
  rb_define_method(cTermInfo, "tputs", rt_tputs, 2);
}
