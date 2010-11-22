#!/usr/bin/env ruby

Index='/usr/ports/INDEX-8'
RevIndex='/var/tmp/ports_revindex'

Libexec_dir='/usr/local/libexec/fastport'
ENV['PATH'] += ":.:#{Libexec_dir}"
$LOAD_PATH << '.' << Libexec_dir
require 'bsearch'


module Enumerable
  def second; drop(1).first end
end

def mk_revindex 
  unless File.exists?(RevIndex) and File.mtime(RevIndex) > File.mtime(Index)
    %x[revindex < #{Index} | sort -k1 > #{RevIndex}]
  end
  open(RevIndex)
end

def lookup_revindex pkg_origin
  $idx ||= mk_revindex
  bsearch_index $idx, pkg_origin
end

def test_revindex
  open(RevIndex) do |f|
    while (l = f.gets) do
      pkg_origin = l.split(' ').first
      r = lookup_revindex pkg_origin
      if r==:not_found
        puts "#{pkg_origin}: not_found"
      else
        puts r
      end
    end
  end
end

def pkg_origin pkg
  open("/var/db/pkg/#{pkg}/+CONTENTS") do |f|
    xs = []; 
    5.times {xs << f.read}
    xs
  end
    .map{|x| x =~ /ORIGIN:(.+)/; $1}.compact.first
  # todo: write a transformer such as 'take first + map', or 'breaking-fold'
end

def get_version pkg_with_ver
  pkg_with_ver.split('-').last
end

def check_pkg pkg
  idx_ver = get_version(lookup_revindex(pkg_origin pkg).split(' ').second)
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
    when '-l' then puts lookup_revindex ARGV.second
    when '-t' then test_revindex
  end
end
