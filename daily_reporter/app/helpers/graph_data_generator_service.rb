class GraphDataGeneratorService

  attr_accessor :project, :project_id, :from_date, :till_date

                def initialize(project, from_date, till_date)
                  @project=project
                  @project_id=project.id
                  @from_date=from_date
                  @till_date=till_date
                end

  def generate_overall_bug_count_graph_data
    issue_query_builder=IssueQueryBuilder.new(@project_id)
    total_issues= issue_query_builder.with_start_date(@from_date).with_end_date(@till_date+1.day)
    .execute_individual_query
    closed_issues = issue_query_builder.with_start_date(@from_date).with_end_date(@till_date+1.day)
    .with_issue_status(StatusWrapper::CLOSED).execute_individual_query

    return [['Closed', closed_issues], ['Open', total_issues - closed_issues]]
  end

  def generate_velocity_of_reduction_graph_data(daily_data_hash)
    data_hash={}
    new_inProgress_sum = get_array_sum(daily_data_hash[StatusWrapper::NEW], daily_data_hash[StatusWrapper::REWORK])
    closed_complete_sum = get_array_sum(daily_data_hash[StatusWrapper::COMPLETED], daily_data_hash[StatusWrapper::CLOSED])

    data_hash["Velocity"]=get_array_difference(closed_complete_sum, new_inProgress_sum)
    data_hash["Avg-velocity"]=get_velocity_average_data(data_hash["Velocity"])
    return data_hash
  end

  def generate_todays_graph_data
    daily_data_hash = {}
    get_issue_status_hash.each_pair { |status_name, status_id|
      report_data=Array.new
      (from_date..till_date).select { |day|
        issue_query_builder=IssueQueryBuilder.new(@project_id)
        issue_query_builder.with_start_date(day)
        issue_query_builder.with_end_date(day+1.day)
        count=0
        if status_id==StatusWrapper::NEW
        count=issue_query_builder.execute_individual_query
        else
          issue_query_builder.with_issue_status(status_id)
        count=issue_query_builder.execute
        end
        report_data<<count
      }
      daily_data_hash[status_id]=report_data
    }
    return daily_data_hash
  end

  def generate_issue_list_data(status_id,priority_id,module_id)
      report_data=Array.new
        issue_query_builder=IssueQueryBuilder.new(@project_id)
        issue_query_builder.with_start_date(@from_date)
        issue_query_builder.with_end_date(@till_date)
        if status_id.to_i==StatusWrapper::NEW
          issue_data_list=issue_query_builder.with_created_on_or_before(@from_date).with_updated_on_or_before(nil).execute_query_for_list
        elsif status_id.to_i==StatusWrapper::CLOSED
          issue_data_list=issue_query_builder.with_updated_on_or_before(@from_date).with_created_on_or_before(nil)
          .with_issue_status(status_id.to_i).execute_query_for_list
        elsif !priority_id.nil?
          issue_data_list=issue_query_builder.with_updated_on_or_before(@from_date).with_created_on_or_before(nil)
          .with_issue_priority(priority_id.to_i).execute_query_for_priority
        else
          issue_query_builder.with_issue_status(status_id.to_i) unless status_id.nil?
          issue_query_builder.with_module_id(module_id.to_i) unless module_id.nil?
          issue_query_builder.with_issue_priority(priority_id.to_i) unless priority_id.nil?
          issue_data_list=issue_query_builder.execute_list
        end
        issue_data_list.each do |row|
          report_data<<[row["id"],row["subject"],User.find_by_id(row["assigned_to_id"]),User.find_by_id(row["author_id"])]
        end
    return report_data
  end

  def generate_open_issues_by_priority_graph_data
    report_data_hash={}
    priorities_hash={"Low" => 3, "Normal" => 4, "High" => 5, "Urgent" => 6, "Immediate" => 7}
    priorities_hash.each_pair { |priority, priority_id|
      priority_array=Array.new
      (from_date..till_date).select { |day|
        issue_query_builder=IssueQueryBuilder.new(@project_id)
        temp_date=day + 1.day
        total_issue_count=issue_query_builder.with_created_on_or_before(temp_date).with_issue_priority(priority_id).execute_individual_query
        closed_issue_count = issue_query_builder.with_issue_status(StatusWrapper::CLOSED).with_created_on_or_before(nil).with_issue_priority(priority_id).with_updated_on_or_before(temp_date).execute_individual_query
        priority_array<<(total_issue_count - closed_issue_count)
      }
      report_data_hash[priority]=priority_array
    }
    return report_data_hash
  end

  def generate_open_issues_by_module_graph_data
    data_hash={}
    project_modules = IssueWrapper.get_project_modules(project.id)
    project_modules.each do |project_module|
      report_data=Array.new
      (from_date..till_date).select { |day|
        issue_query_builder=IssueQueryBuilder.new(@project_id)
        temp_date=day + 1.day
        total_issue_count=issue_query_builder.with_created_on_or_before(temp_date).with_module_id(project_module.id).execute_individual_query
        closed_issue_count = issue_query_builder.with_issue_status(StatusWrapper::CLOSED).with_created_on_or_before(nil).with_module_id(project_module.id).with_updated_on_or_before(temp_date).execute_individual_query
        report_data<<(total_issue_count - closed_issue_count)
      }
      data_hash[project_module.name]=report_data
    end
    return data_hash

  end

  def generate_rework_percentage_graph_data
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
      issue_builder=IssueQueryBuilder.new(@project_id)
      issue_builder.with_start_date(day).with_end_date(day+1.day)
      closed_issue_array << issue_builder.with_issue_status(StatusWrapper::CLOSED).execute
      rework_issue_array << issue_builder.with_issue_status(StatusWrapper::REWORK).execute
      resolved_issue_array << issue_builder.with_issue_status(StatusWrapper::COMPLETED).execute
    }
    rework_percentage.data = compute_rework_percentage(rework_issue_array, closed_issue_array, resolved_issue_array)
    avg_rework_percentage.data = compute_rework_average(rework_percentage.data)
    aggregator.status_data_list<<rework_percentage
    aggregator.status_data_list<<avg_rework_percentage
    return aggregator.to_series_json

  end

  def generate_rework_by_dev_graph_data
    dev_data_array = []
      issue_builder=IssueQueryBuilder.new(@project_id)
      issue_builder.with_issue_status(StatusWrapper::REWORK).with_grouping_criteria("assigned_to_id")
      user_rework_data=issue_builder.execute_query_by_user
      user_rework_data.each do |dev_id , rework_count|
        dev_data_array<<[User.find(dev_id).firstname,rework_count] unless rework_count.eql?0
      end
    return dev_data_array
  end

  def generate_closed_issues_by_dev_graph_data
    dev_data_array = []
    issue_builder=IssueQueryBuilder.new(@project_id)
    issue_builder.with_issue_status(StatusWrapper::COMPLETED).with_grouping_criteria("author_id")
    user_closed_data=issue_builder.execute_query_by_user
    user_closed_data.each do |dev_id , completed_count|
      user=User.find(dev_id)
      name=user.firstname
      if name==""
        name=user.lastname
      end
      dev_data_array<<[name,completed_count] unless completed_count.eql?0
    end
    return dev_data_array
  end

  def generate_day_wise_open_issues_data
    report_data=Array.new
    (from_date..till_date).select { |day|
      issue_query_builder=IssueQueryBuilder.new(@project_id)
      temp_date=day + 1.day
      total_issue_count=issue_query_builder.with_created_on_or_before(temp_date).execute_individual_query
      closed_issue_count = issue_query_builder.with_issue_status(StatusWrapper::CLOSED).with_created_on_or_before(nil).with_updated_on_or_before(temp_date).execute_individual_query
      report_data<<(total_issue_count - closed_issue_count)
    }
    return report_data

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

  private
  def get_velocity_average_data(velocity_data)
    avg_velocity_array = Array.new
    avg_velocity_array[0]=velocity_data[0]
    for index in (1...velocity_data.length)
      avg_velocity_array[index] = (velocity_data[0]+velocity_data[index])/ (index + 1)
    end
    return avg_velocity_array
  end

  def compute_rework_percentage(rework_array, closed_array, completed_array)
    rework_percentage = Array.new
    if rework_array.nil? || !rework_array.respond_to?("each")
      return nil
    end
    sum_array = get_array_sum(closed_array, completed_array)
    for index in (0...rework_array.length)
      begin
        rework_percentage[index] = ((rework_array[index] * 100)/sum_array[index])
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

end
