#!/usr/bin/env ruby
puts "[GTN/Dedupe] Locating Duplicates"
results = `fdupes -r topics assets`.split("\n\n")
puts "[GTN/Dedupe] Found #{results.length} groups of duplicates"

DOIT = false

class Integer
  def to_filesize
    {
      'B'  => 1024,
      'KB' => 1024 * 1024,
      'MB' => 1024 * 1024 * 1024,
      'GB' => 1024 * 1024 * 1024 * 1024,
      'TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return "#{(self.to_f / (s / 1024)).round(2)}#{e}" if self < s }
  end
end

results.map!{|x| x.split(/\n/)}
results.select!{|x| x[0] !~ /(md|bib|sh|yaml)$/}

puts "[GTN/Dedupe] Filtered down to #{results.length} duplicates that are actionable"

def replace_dupe(original, duplicate)
  folder = File.dirname(duplicate)
  upup = folder.split('/').map{|x| ".."}.join('/') # yes only on linux, no I don't care.
  target = upup + '/' + original
  #puts "Replacing #{duplicate} with symlink to #{target}"
  File.unlink(duplicate)
  File.symlink(target, duplicate)
end

wasted_total = 0
results.each{|files|
  puts "Duplicates: #{files}"
  puts "Wasted: " + files[1..].map{|dupe|
    File.size(dupe)
  }.sum.to_filesize

  files[1..].each{|dupe|
    wasted_total += File.size(dupe)
    if DOIT
      replace_dupe(files[0], dupe)
    end
  }
}

puts "Total wasted space: #{wasted_total.to_filesize}"
