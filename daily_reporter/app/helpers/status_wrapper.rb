module StatusWrapper
  include Enumerable
  @status_hash = {}
  attr_accessor :mapping_name, :id


  def StatusWrapper.add_status(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def StatusWrapper.add_completed(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def StatusWrapper.add_reworked(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def StatusWrapper.add_in_progress(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def StatusWrapper.add_new(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def add_closed(mapped_name, id)
    @status_hash[mapped_name] = id
  end

  def StatusWrapper.const_missing(key)
    return @status_hash[key]
  end

  def each
    @status_hash.each { |key, value| yield(key, value) }
  end
end