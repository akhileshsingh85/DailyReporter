class IssueQueryBuilder
  attr_accessor :base_query, :issue_priority, :issue_module, :issue_owner, :inner_query,
                :start_date, :end_date, :project_id, :created_on ,:group_criteria , :issue_author,
                :updated_on


  def initialize(project_id)
    @project_id=project_id
  end

  def with_issue_priority(priority_id)
    @issue_priority=priority_id
    return self
  end

  def with_issue_status(issue_status)
    @issue_status=issue_status
    return self
  end

  def with_owner(owner_id)
    @issue_owner=owner_id
    return self
  end

  def with_module_id(module_id)
    @issue_module=module_id
    return self
  end

  def with_created_on_or_before(created_on)
    @created_on=created_on
    return self
  end

  def with_updated_on_or_before(updated_on)
    @updated_on=updated_on
    return self
  end

  def with_start_date(start_date)
    @start_date=start_date
    return self
  end

  def with_end_date(end_date)
    @end_date=end_date
    return self
  end

  def with_author(author_id)
    @issue_author=author_id
    return self
  end
  def with_grouping_criteria(group_citeria)
    @group_criteria=group_citeria
    return self
  end

  def execute_individual_query

    @base_query= Issue.where(
        :tracker_id => 1
    )
    if (!@created_on.nil?)
      @base_query=@base_query.where("issues.created_on <= '#{@created_on}'")
    elsif (!@updated_on.nil?)
      @base_query=@base_query.where("issues.updated_on <='#{@updated_on}'")
    else
      @base_query=@base_query.where(:created_on => @start_date..@end_date)
    end
    @base_query=@base_query.where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})") unless @project_id.nil?
    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.status_id=#{@issue_status}") unless @issue_status.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    @base_query=@base_query.where("issues.author_id=#{@issue_author}") unless @issue_author.nil?
    puts (@base_query.to_sql)
    return @base_query.count
  end

  def execute
    @base_query=Issue.joins("inner join journals journals on issues.id=journals.journalized_id")
    .joins("inner join journal_details journal_details on journals.id=journal_details.journal_id")
    .where("journal_details.prop_key='status_id' and journals.journalized_type = 'Issue' ")
    .where("journals.journalized_type = 'Issue' and issues.tracker_id=1")
    .where("journal_details.value='#{@issue_status}'")
    .where("journals.created_on between '#{@start_date}' AND '#{@end_date}'")
    .where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})")
    .where("journals.created_on =(select max(another_journal.created_on) from journals another_journal  where another_journal.journalized_id = issues.id and created_on between '#{@start_date}' AND '#{@end_date}' )")


    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    puts (@base_query.to_sql)
    return @base_query.count
  end

  def execute_query_by_user
    @base_query= Issue.joins(:assigned_to).where(
        :tracker_id => 1
    )
    @base_query=@base_query.where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})") unless @project_id.nil?
    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.status_id=#{@issue_status}") unless @issue_status.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    @base_query=@base_query.where("issues.author_id=#{@issue_author}") unless @issue_author.nil?
    @base_query=@base_query.group(@group_criteria) unless @group_criteria.nil?
    puts (@base_query.to_sql)
    return @base_query.count
  end

  def execute_list
    @base_query=Issue.joins("inner join journals journals on issues.id=journals.journalized_id")
    .joins("inner join journal_details journal_details on journals.id=journal_details.journal_id")
    .where("journal_details.prop_key='status_id' and journals.journalized_type = 'Issue' ")
    .where("journals.journalized_type = 'Issue' and issues.tracker_id=1")
    .where("journals.created_on between '#{@start_date}' AND '#{@end_date}'")
    .where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})")
    .where("journals.created_on =(select max(another_journal.created_on) from journals another_journal  where another_journal.journalized_id = issues.id and created_on between '#{@start_date}' AND '#{@end_date}' )")

    @base_query=@base_query.where("journal_details.value='#{@issue_status}'") unless @issue_status.nil?
    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    puts (@base_query.to_sql)
    return @base_query.select('issues.id,issues.subject,issues.assigned_to_id,issues.author_id')
  end

  def execute_query_for_list
    @base_query= Issue.where(
        :tracker_id => 1
    )
    @base_query=@base_query.where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})") unless @project_id.nil?
    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.status_id=#{@issue_status}") unless @issue_status.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    @base_query=@base_query.where("issues.author_id=#{@issue_author}") unless @issue_author.nil?
    @base_query=@base_query.where("issues.updated_on between '#{@updated_on}' AND '#{@updated_on+1.day}'") unless @updated_on.nil?
    @base_query=@base_query.where("issues.created_on between '#{@created_on}' AND '#{@created_on+1.day}'") unless @created_on.nil?

    puts (@base_query.to_sql)
    return @base_query.select('issues.id,issues.subject,issues.assigned_to_id,issues.author_id')
  end

  def execute_query_for_priority
    @base_query= Issue.where(
        :tracker_id => 1
    )
    @base_query=@base_query.where("issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id = #{project_id})") unless @project_id.nil?
    @base_query=@base_query.where("issues.priority_id=#{@issue_priority}") unless @issue_priority.nil?
    @base_query=@base_query.where("issues.status_id=#{@issue_status}") unless @issue_status.nil?
    @base_query=@base_query.where("issues.category_id=#{@issue_module}") unless @issue_module.nil?
    @base_query=@base_query.where("issues.assigned_to_id=#{@issue_owner}") unless @issue_owner.nil?
    @base_query=@base_query.where("issues.author_id=#{@issue_author}") unless @issue_author.nil?
    @base_query=@base_query.where("issues.updated_on between '#{@updated_on}' AND '#{@updated_on+1.day}'") unless @updated_on.nil?
    @base_query=@base_query.where("issues.created_on between '#{@created_on}' AND '#{@created_on+1.day}'") unless @created_on.nil?
    @base_query=@base_query.where("issues.id NOT in (SELECT `issues`.id FROM `issues`  WHERE `issues`.`tracker_id` = 1 AND (`issues`.`created_on` BETWEEN #{@updated_on} AND #{@updated_on+1.day}) AND (issues.project_id IN (SELECT p.id FROM projects as p where p.parent_id = #{project_id} or p.id =  #{project_id})) AND (issues.status_id=3)")

    puts (@base_query.to_sql)
    return @base_query.select('issues.id,issues.subject,issues.assigned_to_id,issues.author_id')
  end

end