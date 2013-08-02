module PriorityWrapper
  include Enumerable
  @priority_hash = {}
  attr_accessor :mapping_name, :id


  def PriorityWrapper.add_priority(mapped_name, id)
    @priority_hash[mapped_name] = id
  end

  def PriorityWrapper.const_missing(key)
    return @priority_hash[key]
  end

  def each
    @priority_hash.each { |key, value| yield(key, value) }
  end
end