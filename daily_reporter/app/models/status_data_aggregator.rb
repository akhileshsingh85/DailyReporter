class StatusDataAggregator < ReportData
  attr_accessor :status_data_list
  def initialize()
    @status_data_list=Array.new
  end

 def to_series_json
   return status_data_list.to_json
 end

end



