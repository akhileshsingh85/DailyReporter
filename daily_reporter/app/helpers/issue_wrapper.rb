module IssueWrapper
  attr_accessor :name, :id

  def self.get_total_issues(date, project_id)
    return Issue.where("created_on <= ? and project_id = ? and tracker_id = 1", date, project_id).count("id")
  end

  def self.get_issues_till_date(date, issue_status, project_id)
    if (issue_status==StatusWrapper::NEW)
      return Issue.where("created_on <= ? and project_id = ? and tracker_id = 1", date, project_id).count("id")
    end
    return Issue.where("created_on <= ? and project_id = ? and status_id = ? and tracker_id = 1", date, project_id, issue_status).count("id")
  end

  def self.get_issues_till_date_by_priority(date, issue_status, project_id, priority_id)
    if (issue_status==StatusWrapper::NEW)
      return Issue.where("created_on < ? and project_id = ? and priority_id = ? and tracker_id = 1", date, project_id, priority_id).count("id")
    end
    return Issue.where("created_on < ? and project_id = ? and status_id = ? and priority_id = ? and tracker_id = 1", date, project_id, issue_status, priority_id).count("id")
  end

  def self.get_issues_till_date_for_module(date, issue_status, project_id, module_id)
    if (issue_status==StatusWrapper::NEW)
      return Issue.where("created_on < ? and project_id = ? and category_id = ? and tracker_id = 1", date, project_id, module_id).count("id")
    end
    return Issue.where("created_on < ? and project_id = ? and status_id = ? and category_id = ? and tracker_id = 1", date, project_id, issue_status, module_id).count("id")
  end

  def self.get_new_issues(start_date, end_date, project_id)
    return Issue.where(
        :created_on => start_date..end_date,
        :project_id => project_id,
        :tracker_id => 1,
        :status_id => StatusWrapper::NEW
    ).count
  end

  def self.get_closed_issues(start_date, end_date, project_id)
    return Issue.where(
        :created_on => start_date..end_date,
        :project_id => project_id,
        :status_id => StatusWrapper::CLOSED,
        :tracker_id => 1
    ).count
  end

  def self.get_issues_on_day(date, issueStatus, project_id)
    return get_issues_between_days(date, date+1.day, issueStatus, project_id)
  end


  def self.get_issues_between_days(start_date, end_date, issueStatus, project_id)

    if (issueStatus==StatusWrapper::NEW)
      return get_new_issues(start_date, end_date, project_id)
    end

    if (issueStatus==StatusWrapper::CLOSED)
      return get_closed_issues(start_date, end_date, project_id)
    end

    query = "Select count(issues.id) from issues issues
    inner join journals journals on issues.id=journals.journalized_id
    inner join journal_details details on journals.id=details.journal_id
    where details.prop_key = 'status_id' and details.value = #{issueStatus}
    and journals.journalized_type = 'Issue' and  journals.created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59'
    and issues.project_id = #{project_id} and issues.tracker_id = 1
    and journals.created_on = (select max(another_journal.created_on) from journals another_journal  where another_journal.journalized_id = issues.id and created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59' )"

    result = ActiveRecord::Base.connection.execute(query);
    result.each do |row|
      return row[0]
    end

  end

  def self.get_issues_between_days_by_priority(start_date, end_date, project_id, issueStatus, priority_id)
    if (issueStatus==StatusWrapper::NEW)
      return get_new_issues_by_priority(start_date, end_date, project_id, priority_id)

    end

    (priority_sql="and issues.priority_id = #{priority_id}")
    if  priority_id.nil?
      priority_sql=""
    end

    query = "Select count(issues.id) from issues issues
    inner join journals journals on issues.id=journals.journalized_id
    inner join journal_details details on journals.id=details.journal_id
    where details.prop_key = 'status_id' and details.value='#{issueStatus}'
    and journals.journalized_type = 'Issue' and  journals.created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59'
    and issues.project_id = #{project_id} and issues.tracker_id=1 #{priority_sql}
    and journals.created_on =(select max(another_journal.created_on) from journals another_journal  where another_journal.journalized_id = issues.id and created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59' )"

    result = ActiveRecord::Base.connection.execute(query);
    result.each do |row|
      resultData = row[0]
      return resultData
    end

  end

  def self.get_new_issues_by_priority(start_date, end_date, project_id, priority_id)
    return Issue.where(
        :created_on => start_date..end_date,
        :project_id => project_id,
        :priority_id => priority_id
    ).count
  end

  def self.get_issues_between_days_for_module(start_date, end_date, project_id, issueStatus, project_module_id)
    if (issueStatus==StatusWrapper::NEW)
      return get_new_issues_for_module(start_date, end_date, project_id, project_module_id)
    end

    (module_sql="and issues.category_id = #{project_module_id}")
    if  priority_id.nil?
      module_sql=""
    end

    query = "Select count(issues.id) from issues issues
    inner join journals journals on issues.id=journals.journalized_id
    inner join journal_details details on journals.id=details.journal_id
    where details.prop_key = 'status_id' and details.value='#{issueStatus}'
    and journals.journalized_type = 'Issue' and  journals.created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59'
    and issues.project_id = #{project_id} and issues.tracker_id=1 #{module_sql}
    and journals.created_on =(select max(another_journal.created_on) from journals another_journal  where another_journal.journalized_id = issues.id and created_on between '#{start_date} 00:00:00 ' AND '#{end_date} 23:59:59' )"

    result = ActiveRecord::Base.connection.execute(query);
    result.each do |row|
      return row[0]
    end
  end

  def self.get_new_issues_for_module(start_date, end_date, project_id, project_module_id)
    return Issue.where(
        :created_on => start_date..end_date,
        :project_id => project_id,
        :category_id => project_module_id,
        :tracker_id => 1
    ).count
  end

  def self.get_project_modules(project_id)
    return IssueCategory.where(:project_id => project_id)
  end

  def self.get_issue_status_by_user(start_date, end_date, project_id, issue_status_id, role_id)
    query =
        "select DISTINCT(u.login), count(i.id) from issues i
      inner join issue_statuses istatus on i.status_id = istatus.id
      inner join projects p on i.project_id = p.id
      inner join users u on i.assigned_to_id = u.id
        where istatus.id = #{issue_status_id}
        and p.id = #{project_id}
        and u.id in
        (select m.user_id from members m inner join member_roles mr on m.id = mr.member_id and mr.role_id = #{role_id})
        and i.created_on between '#{start_date}' and '#{end_date}'
        GROUP BY u.login"
    result = ActiveRecord::Base.connection.execute(query);
    rework_issue_by_user=[]
    result.each do |name, rework_issue|
       rework_issue_by_user << ["#{name}", rework_issue]
    end
    return rework_issue_by_user
  end

  def self.get_issues_by_author(project_id, tracker_id, status_id)
    query =
      "select DISTINCT(u.login), COUNT(i.id) from issues i
	      INNER JOIN projects p ON p.id = i.project_id
	      INNER JOIN users u ON u.id = i.author_id
      WHERE p.id = #{project_id}
      AND i.status_id = #{status_id}
      AND i.tracker_id = #{tracker_id}
      GROUP BY u.login"
    result = ActiveRecord::Base.connection.execute(query);
    defects_by_author=[]
    result.each do |author, defects|
      defects_by_author << ["#{author}", defects]
    end
    return defects_by_author
  end
end


