class SecretSanta
  def self.pair(list, blacklist = {})
    name_list = list.keys
    name_list.shuffle!

    name_list.each.with_index.reduce([]) do |paired_list, (name, index)|
      pairs = assign_pair(index, name_list)

      if blacklist[name] != pairs[name]
        paired_list << {:name => name, :email => list[name], :pair => pairs[name]}
      else
        []
      end
    end
  end

  def self.assign_pair(index, name_list)
    next_index = (index + 1) == name_list.size ? 0 : index + 1
    { name_list[index] => name_list[next_index] }
  end
end
