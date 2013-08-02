class ReportGeneratorController < ApplicationController
  unloadable


  before_filter :find_project, :authorize => :index; :get_issue_list_data
  before_filter :set_status_settings

  def index
    @project_id=params[:project_id]
    @date_range=params[:selectedDates]
    flag=request.method.eql? "GET"

    if ((!@date_range.nil? && !@date_range.empty?) || flag)

      begin

        from_date=Date.strptime(@date_range.split("-").first.strip, '%m/%d/%Y') unless flag
        till_date=Date.strptime(@date_range.split("-").last.strip, '%m/%d/%Y') unless flag
        project_created_date=@project.created_on.to_date

        from_date= flag ? Date.today - 7.day : from_date < project_created_date ? project_created_date : from_date > Date.today ? Date.today : from_date
        till_date= flag ? Date.today : till_date.nil? ? from_date : till_date < project_created_date ? project_created_date : till_date > Date.today ? Date.today : till_date
        @fixed_version=Version.find(:all, :conditions => ["project_id =?", @project.id])
        @graph_service=GraphDataGeneratorService.new(@project, from_date, till_date)
        @daily_data_hash = @graph_service.generate_todays_graph_data
        @categoryData = (from_date..till_date).to_a
        @pieData = @graph_service.generate_overall_bug_count_graph_data
        @seriesData = get_json_report_status(@daily_data_hash)
        @velocityData = get_json_report_data(@graph_service.generate_velocity_of_reduction_graph_data(@daily_data_hash))

        @openIssuesByPriorityData = get_json_report_data(@graph_service.generate_open_issues_by_priority_graph_data)
        @openIssuesForProjectModuleData = get_json_report_data(@graph_service.generate_open_issues_by_module_graph_data)

        @reworkPercentageData = @graph_service.generate_rework_percentage_graph_data
        @reworkByDev = @graph_service.generate_rework_by_dev_graph_data
        @defectsByAuthor = @graph_service.generate_closed_issues_by_dev_graph_data
        @openIssueCount = @graph_service.generate_day_wise_open_issues_data
        @start_date=from_date
        @end_date= till_date
      rescue Exception => exc
        logger.error("Logger [Error] : #{exc.message}")
        @error= "Please check the date format[mm/dd/yyyy-mm/dd/yyyy] or refer the server log file: #{exc.message}"
        @date_range = ''
      end
    end
  end

  def get_issue_list_data
    priorities_hash={"Low" => 3, "Normal" => 4, "High" => 5, "Urgent" => 6, "Immediate" => 7}
    @project_id=params[:project_id]
    @issue_data_array=Array.new
    @selected_date=Date.parse(params[:selected_date]) unless params[:selected_date].nil?
    @start_date=Date.parse(params[:start_date]) unless params[:start_date].nil?
    @end_date=Date.parse(params[:end_date]) unless params[:end_date].nil?
    @status_name=params[:status_id]
    @project_name=params[:priority_id]
    @module_name=params[:module_id]
    graph_service=GraphDataGeneratorService.new(@project, @start_date, @end_date) unless @start_date.nil?
    graph_service=GraphDataGeneratorService.new(@project, @selected_date, @selected_date+1.day) unless @selected_date.nil?
    status_id=graph_service.get_issue_status_hash[@status_name]
    priority_id=priorities_hash[@project_name]
    module_id=params[:module_id]
    @issue_list_data= graph_service.generate_issue_list_data(status_id, priority_id, module_id)
    @title_name= !@status_name.nil? ? @status_name : !@project_name.nil? ? @project_name : @module_name.nil? ? @module_name :''
    @selected_date= @selected_date.nil? ? "#{@start_date} - #{@end_date}" : @selected_date
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end

  def set_status_settings
    IssueStatusHelper.set_status_settings
  end

  private
  def get_json_report_data(data_hash)
    aggregator=StatusDataAggregator.new
    data_hash.each_pair { |hash_name, hash_data|
      report_data=ReportData.new(hash_name)
      report_data.data=hash_data
      aggregator.status_data_list<<report_data
    }
    return aggregator.to_series_json
  end

  def get_json_report_status(report_status)
    aggregator=StatusDataAggregator.new
    @graph_service.get_issue_status_hash.each_pair { |issue_name, issue_id|
      report_data=ReportData.new(issue_name)
      report_data.data=report_status[issue_id]
      aggregator.status_data_list<<report_data
    }
    return aggregator.to_series_json
  end
end