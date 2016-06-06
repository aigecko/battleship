#!/usr/bin/ruby
require 'mkmf'

ext_name = 'MHPlayer'

dir_config(ext_name)

create_makefile(ext_name)
