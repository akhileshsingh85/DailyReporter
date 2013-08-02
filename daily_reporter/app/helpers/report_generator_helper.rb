module ReportGeneratorHelper


  def get_velocity_rate_data(new_issue_array, rework_issue_array, complete_issue_array, closed_issue_array)
    aggregator=StatusDataAggregator.new
    new_inProgress_sum = get_array_sum(new_issue_array, rework_issue_array)
    closed_complete_sum = get_array_sum(complete_issue_array, closed_issue_array)

    velocity_data=ReportData.new("Velocity")
    velocity_data.data=get_array_difference(closed_complete_sum, new_inProgress_sum)
    aggregator.status_data_list<<velocity_data

    report_data=ReportData.new("Avg-velocity")
    report_data.data=get_velocity_average_data(velocity_data.data)

    aggregator.status_data_list<<report_data
    return aggregator.to_series_json
  end

  def get_velocity_average_data(velocity_data)
    avg_velocity_array = Array.new
    avg_velocity_array[0]=velocity_data[0]
    for index in (1...velocity_data.length)
      avg_velocity_array[index] = (velocity_data[0]+velocity_data[index])/ (index + 1)
    end
    return avg_velocity_array
  end


  def get_array_sum(first_array, second_array)
    sum_array = Array.new
    for index in (0...first_array.length)
      sum_array[index] = first_array[index] + second_array[index]
    end
    return sum_array
  end

  def get_array_difference(first_array, second_array)
    diff_array = Array.new
    for index in (0...first_array.length)
      diff_array[index] = first_array[index] - second_array[index]
    end
    return diff_array
  end

  def generate_chart_data(from_date, till_date, project)
    closed_issues= IssueWrapper.get_issues_between_days(from_date, till_date, StatusWrapper::CLOSED, project.id)
    total_issues= IssueWrapper.get_total_issues(till_date + 1,project.id)
    return [['Closed', closed_issues], ['Open',total_issues - closed_issues]]
  end

  def get_issue_status_hash
    issue_status_hash={IssueStatus.find(StatusWrapper::NEW).name => StatusWrapper::NEW,
                       IssueStatus.find(StatusWrapper::CLOSED).name => StatusWrapper::CLOSED,
                       IssueStatus.find(StatusWrapper::COMPLETED).name => StatusWrapper::COMPLETED,
                       IssueStatus.find(StatusWrapper::IN_PROGRESS).name => StatusWrapper::IN_PROGRESS,
                       IssueStatus.find(StatusWrapper::REWORK).name => StatusWrapper::REWORK
    }
    return issue_status_hash
  end

  def get_open_issues_on_priority(from_date, till_date, project)
    aggregator=StatusDataAggregator.new
    total_new_issues_count=get_issues_till_date_count(from_date, StatusWrapper::NEW, project.id)
    priorities_hash={"Low" => 3, "Normal" => 4, "High" => 5, "Urgent" => 6, "Immediate" => 7}
    priorities_hash.each_pair { |priority, priority_id|
      report_data=ReportData.new(priority)
      (from_date..till_date).select {|day|
        new_issue_count = get_issue_status_count_on_day_priority(day, StatusWrapper::NEW, project.id, priority_id)
        rework_issue_count = get_issue_status_count_on_day_priority(day, StatusWrapper::REWORK, project.id, priority_id)
        inProgress_issue_count = get_issue_status_count_on_day_priority(day, StatusWrapper::IN_PROGRESS, project.id, priority_id)
        report_data.data<<(new_issue_count + rework_issue_count + inProgress_issue_count)
      }
      aggregator.status_data_list<<report_data
    }
    aggregator.to_series_json
  end

  def get_open_issues_day_wise(from_date, till_date, project)
    report_data=Array.new
    (from_date..till_date).select { |day|
      temp_date=day + 1
      total_issue_count = IssueWrapper.get_total_issues(temp_date,project.id)
      closed_issue_count = IssueWrapper.get_issues_till_date(temp_date,StatusWrapper::CLOSED,project.id)
      report_data<<(total_issue_count - closed_issue_count)
    }
    return report_data
  end


  def get_issue_status_count_on_day_priority(date, issueStatus, project_id, priority_id)
    start_date=date
    till_date=start_date+1.day
    return IssueWrapper.get_issues_between_days_by_priority(start_date, till_date, project_id, issueStatus, priority_id)
  end

  def get_open_issues_for_project_module(from_date, till_date, project)
    aggregator=StatusDataAggregator.new
    project_modules = IssueWrapper.get_project_modules(project.id)
    project_modules.each do |project_module|
      report_data=ReportData.new(project_module.name)
      (from_date..till_date).select {|day|
        new_issue_count = get_issue_status_count_on_day_for_module(day, StatusWrapper::NEW, project.id, project_module.id)
        rework_issue_count = IssueWrapper.get_issues_on_day(day, StatusWrapper::REWORK, project_module.id)
        inProgress_issue_count = IssueWrapper.get_issues_on_day(day, StatusWrapper::IN_PROGRESS, project_module.id)
        report_data.data<<(new_issue_count + rework_issue_count + inProgress_issue_count)
      }
      aggregator.status_data_list<<report_data
    end
     return aggregator.to_series_json
  end

  def get_issue_status_count_on_day_for_module(date, issueStatus, project_id, project_module_id)
    start_date=date
    till_date=start_date+1.day
    return IssueWrapper.get_issues_between_days_for_module(start_date, till_date, project_id, issueStatus, project_module_id)
  end

  def get_issues_till_date_count(date, issueStatus, project_id)
      return  IssueWrapper.get_issues_till_date(date, issueStatus, project_id)
  end

  # Returns the rework percentage
  def get_rework_percentage(from_date, till_date, project)
    # Initialize data aggregator to send data back in JSON format
    aggregator = StatusDataAggregator.new
    # Calculate Rework Percentage
    rework_percentage = ReportData.new("Rework Percentage")
    # Calculate Average Rework Percentage
    avg_rework_percentage = ReportData.new("Avg Rework Percentage")
    closed_issue_array = Array.new
    rework_issue_array = Array.new
    resolved_issue_array = Array.new
    (from_date..till_date).select { |day|
      closed_issue_array << IssueWrapper.get_issues_on_day(day, StatusWrapper::CLOSED, project.id)
      rework_issue_array << IssueWrapper.get_issues_on_day(day, StatusWrapper::REWORK, project.id)
      resolved_issue_array << IssueWrapper.get_issues_on_day(day, StatusWrapper::COMPLETED, project.id)
    }
    rework_percentage.data = compute_rework_percentage(rework_issue_array, closed_issue_array, resolved_issue_array)
    avg_rework_percentage.data = compute_rework_average(rework_percentage.data)
    aggregator.status_data_list<<rework_percentage
    aggregator.status_data_list<<avg_rework_percentage
    return aggregator.to_series_json
  end

  # Computes the rework percentage
  def compute_rework_percentage(rework_array, closed_array, completed_array)
    rework_percentage = Array.new
    if rework_array.nil? || !rework_array.respond_to?("each")
      return nil
    end
    sum_array = get_array_sum(closed_array, completed_array)
    for index in (0...rework_array.length)
      begin
        rework_percentage[index] = ((rework_array[index] * 100 )/sum_array[index])
      rescue
        rework_percentage[index] = 0
      end
    end
    return rework_percentage
  end

  # Computes the average rework percentage
  def compute_rework_average(rework_percentage)
    if rework_percentage.nil? || !rework_percentage.respond_to?("each")
      return nil
    end
    avg_rework_percentage = Array.new
    avg_rework_percentage[0] = rework_percentage[0]
    for index in (1...rework_percentage.length)
      sum_rework_percentage = 0
      x = index;
      while x > 0
        if !rework_percentage[x].nil?
          sum_rework_percentage += rework_percentage[x]
        end
        x = x - 1
      end
      avg_rework_percentage[index] = sum_rework_percentage / (index + 1)
    end
    return avg_rework_percentage
  end

  def get_rework_by_dev(start_date, end_date, project)
    role_id = 4
    return IssueWrapper.get_issue_status_by_user(start_date, end_date, project.id, StatusWrapper::NEW, role_id)
  end

  def get_closed_defects_by_author(project)
    tracker_id = 1
    return IssueWrapper.get_issues_by_author(project.id, tracker_id, StatusWrapper::COMPLETED)
  end
end



