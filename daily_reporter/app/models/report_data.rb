class ReportData
  attr_accessor :name,:data
  def initialize(name)
    @name=name
    @data=Array.new
  end

  def to_series_json(*a)
    {
        'name' => @name,
        'data' => @data
    }.to_json(*a)
  end

end