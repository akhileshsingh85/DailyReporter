##init.rb
Redmine::Plugin.register :daily_reporter do
  name 'Daily Reporter plugin'
  author 'MineSweeper'
  description 'This is a daily reporting plugin for Redmine '
  version '0.1'

  permission :view_reports, :report_generator => :index
  permission :generate_reports, :report_generator => :fetch_report
  permission :report_generator, {:report_generator => [:index, :fetch_report]}


  settings :default => {'priority_low' => 'Low', 'priority_normal' => 'Normal', 'priority_high' => 'High', 'priority_urgent' => 'Urgent', 'priority_immediate' => 'Immediate', 'status_new' => 'New', 'status_in_progress' => 'In Progress', 'status_completed' => 'Completed', 'status_closed' => 'QA Passed', 'status_rework' => 'Re-Work'}, :partial => 'settings/daily_reporter'
  menu :project_menu, :daily_reporter, {:controller => 'report_generator', :action => 'index'}, :caption => 'QA Report ',
       :after => :activity, :param => :project_id

end
require_dependency 'mailer'

module MailerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do

    end

  end

  module ClassMethods

  end

  module InstanceMethods
    #the actual method
    def report(user, date)
      set_language_if_valid(user.language)
      recipients User.current.mail
      subject "Report date #{date.month}/#{date.year}"
      body 'just testing'
      #mail :to =>"ravi@neevtech.com",
      #     :cc => "ravipetlur@gmail.com",
      #     :subject => "Testing"
      render_multipart('report', body)
    end
  end
end

# Add module to Issue
Mailer.send(:include, MailerPatch)
