module IssueStatusHelper
  DEFAULT_STATUSES={"status_new" => :NEW, "status_in_progress" => :IN_PROGRESS, "status_completed" => :COMPLETED, "status_closed" => :CLOSED, "status_rework" => :REWORK}
  DEFAULT_PRIORITIES={'priority_low' => :LOW, 'priority_normal' => :NORMAL, 'priority_high' => :HIGH, 'priority_urgent' => :URGENT, 'priority_immediate' => :IMMEDIATE}

  def self.set_status_settings
    @plugin = Redmine::Plugin.find("daily_reporter")
    @settings = Setting["plugin_#{@plugin.id}"]

    DEFAULT_STATUSES.each_pair { |key, value|
      settings=@settings[key]
      id=IssueStatus.find_by_name(settings).id
      if !id.nil?
        StatusWrapper.add_status(value, IssueStatus.find_by_name(@settings[key]).id)
      end
    }

    DEFAULT_PRIORITIES.each_pair { |key, value|
      settings=@settings[key]
      id=Enumeration.find_by_name(settings).id
      if !id.nil?
        PriorityWrapper.add_priority(value, Enumeration.find_by_name(settings).id)
      end
    }
  end
end