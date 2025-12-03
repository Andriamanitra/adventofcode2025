part1 = part2 = 0
ARGF.read.scan(/\d+/).map(&:to_i).each_slice(2) do |a, b|
  (a..b).each do |id|
    s = id.to_s
    part1 += id if s =~ /^(.+)\1$/
    part2 += id if s =~ /^(.+)\1+$/
  end
end

p part1, part2
