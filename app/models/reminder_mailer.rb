

  class ReminderMailer < ActionMailer::Base

    def untouched_issue_reminder(options={})
      days = options[:days]
      tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil

      # get issues that are older than x days and are NOT closed
      # group them by the assignee so there is only one email for a user
      scope = Issue.open.scoped(:conditions => \
        ["#{Issue.table_name}.updated_on < ?", Time.now-(((60*60)*24)*days)])
      scope = scope.scoped(:conditions => \
        ["#{Project.table_name}.status = #{Project::STATUS_ACTIVE}"])
      scope = scope.scoped(:conditions => \
        {"#{Issue.table_name}.tracker_id" => tracker.id}) if tracker

      issues_by_assignee = scope.all(:include => \
        [:status, :assigned_to, :project, :tracker]) \
        .group_by(&:assigned_to)

      issues_by_assignee.each do |assignee, issues|        
        self.reminder(assignee, issues, days)        
      end
    end

    def reminder(assignee, issues, days)
      @issues = issues
      @days = days
      @issues_url = url_for(:controller => 'issues', :action => 'index',
                                :set_filter => 1, :assigned_to_id => assignee.id,
                                :sort => 'due_date:asc')
      mail :to => assignee.mail, \
           :subject => "#{issues.count} issue(s) that haven't been touched in #{days}"
    end
  end
