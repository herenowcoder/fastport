#!/usr/bin/env ruby

def bsearch f, &compare
  prev_range = []
  loop = lambda do |p1, p2|
    if [p1,p2] != prev_range
      prev_range = [p1,p2]
      f.seek(p1 + ((p2-p1).div 2))
      f.gets # scratch this line remainder
      p = f.pos
      line = f.gets
      return loop.call *prev_range if line.nil?
      line.chomp!
      r = compare.call line
      if r < 0
        loop.call p1, p
      elsif r > 0
        loop.call f.pos, p2
      else
        return line
      end
    else # final search
      f.seek p1
      while (line = f.gets) do
        line.chomp!
        r = compare.call line
        return line if r == 0 
      end
      return :not_found
    end
  end
  loop.call 0, f.size 
end


def portpath_from_indexline x
  i = x.index('|')
  i = x.index('/',i+1)
  i = x.index('/',i+1)
  i = x.index('/',i+1)
  j = x.index('|',i+1)
  x[i+1...j]
end

def bsearch_index f, portpath
  bsearch(f) do |x|
    portpath.sub('/',' ') <=> portpath_from_indexline(x).sub('/',' ')
  end
end
