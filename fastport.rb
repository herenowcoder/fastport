#!/usr/bin/env ruby

Libexec_dir='/usr/local/libexec/fastport'
ENV['PATH'] += ":.:#{Libexec_dir}"
$LOAD_PATH << '.' << Libexec_dir


module Enumerable
  def second; drop(1).first end
end

def guess_index_file
  (release_info = `uname -r`) =~ /^(\d+)[\.-]/
  if $1.nil?
    raise "can't guess release major number from release info: #{release_info}"
  end
  index = "/usr/ports/INDEX-" << $1
  open(index, "r") {}
  index
end

def lookup_index pkg_origin
  $index ||= guess_index_file
  $idx_prog ||= open("|bsearch #{$index}","a+")
  $idx_prog.puts pkg_origin
  $idx_prog.gets
end

def portpath_from_indexline x
  i = x.index('|')
  i = x.index('/',i+1)
  i = x.index('/',i+1)
  i = x.index('/',i+1)
  j = x.index('|',i+1)
  x[i+1...j]
end

def test_index
  open(guess_index_file) do |f|
    while (l = f.gets) do
      pkg_origin = portpath_from_indexline l
      r = lookup_index pkg_origin
      if r=='NOT_FOUND'
        puts "#{pkg_origin}: not_found"
      else
        puts r
      end
    end
  end
end

def pkg_origin pkg
  open("/var/db/pkg/#{pkg}/+CONTENTS") do |f|
    xs = []
    5.times {xs << f.read}
    xs
  end \
    .map{|x| x =~ /ORIGIN:(.+)/; $1}.compact.first
  # todo: write a transformer such as 'take first + map', or 'breaking-fold'
end

def get_version pkg_with_ver
  pkg_with_ver.split('-').last
end

def check_pkg pkg
  idx_ver = get_version(lookup_index(pkg_origin pkg).split('|').first)
  if get_version(pkg) != idx_ver
    puts "installed: #{pkg}, index has: #{idx_ver}"
  end
end

def check_all_pkgs
  Dir.glob('/var/db/pkg/*').map{|f| File.basename f}.each {|x| check_pkg x}
end

if $0 == __FILE__
  case ARGV.first
    when '-u' then check_all_pkgs
    when '-l' then puts lookup_index ARGV.second
    when '-t' then test_index
  end
end
