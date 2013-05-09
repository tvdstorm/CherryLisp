
class CharClass


  def self.unescape(s)
    s = s.gsub(/[\\]\]/, "]")
    s = s.gsub(/[\\]\[/, "[")
    s = s.gsub(/[\\]-/, "-")
    s = s.gsub(/[\\]n/, "\n")
    s = s.gsub(/[\\]n/, "\n")
    s = s.gsub(/[\\]t/, "\t")
    s = s.gsub(/[\\]s/, " ") # non standard
    return s
  end


  def self.match(string)
    if string =~ /^\[((.-.)*)(.*)\]$/    
      suffix = $3 ? unescape($3) : ""
      if $1 then
        list = $1.split('-').collect do |part|
          unescape(part).split('')
        end.flatten
        i = 0
        ranges = []
        while i < list.length - 1 do
          range = list[i]..list[i+1]
          ranges << range
          i += 2
        end
      end
      suffix.split('').each do |char|
        range = char..char
        ranges << range
      end
      return ranges
    end
    return nil
  end


end
