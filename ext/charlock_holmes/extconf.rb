require 'mkmf'

CWD = File.expand_path(File.dirname(__FILE__))
def sys(cmd)
  puts "  -- #{cmd}"
  unless ret = xsystem(cmd)
    raise "#{cmd} failed, please report issue on https://github.com/brianmario/charlock_holmes"
  end
  ret
end

if `which make`.strip.empty?
  STDERR.puts "\n\n"
  STDERR.puts "***************************************************************************************"
  STDERR.puts "*************** make required (apt-get install make build-essential) =( ***************"
  STDERR.puts "***************************************************************************************"
  exit(1)
end

##
# ICU dependency
#

src = File.basename('icu4c-49_1_2-src.tgz')
dir = File.basename('icu')

rubyopt = ENV.delete("RUBYOPT")
  FileUtils.rm_rf(dir) if File.exists?(dir)

  sys("tar zxvf #{src}")
  Dir.chdir(File.join(dir, 'source')) do
    sys("LDFLAGS= CXXFLAGS=\"-O2 -fPIC\" CFLAGS=\"-O2 -fPIC\" ./configure --prefix=#{CWD}/dst/ --disable-tests --disable-samples --disable-icuio --disable-extras --disable-layout --enable-static --disable-shared")
    $LDFLAGS  << " -L#{icu4c}/lib "
    sys("make install")
  end
end

dir_config 'icu'

$INCFLAGS << " -I#{CWD}/dst/include "
$LDFLAGS  << " -L#{CWD}/dst/lib"

unless have_library 'icui18n' and have_library 'icudata' and have_library 'icutu' and have_library 'icuuc' and have_header 'unicode/ucnv.h'
  STDERR.puts "\n\n"
  STDERR.puts "***************************************************************************************"
  STDERR.puts "********* error compiling and linking icu4c. please report issue on github *********"
  STDERR.puts "***************************************************************************************"
  exit(1)
end

have_library 'z' or abort 'libz missing'
have_library 'icuuc' or abort 'libicuuc missing'
have_library 'icudata' or abort 'libicudata missing'

$CFLAGS << ' -Wall -funroll-loops'
$CFLAGS << ' -Wextra -O0 -ggdb3' if ENV['DEBUG']
$LIBS << " -lstdc++"

ENV['RUBYOPT'] = rubyopt
create_makefile 'charlock_holmes/charlock_holmes'
