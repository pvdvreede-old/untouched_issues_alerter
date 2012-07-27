namespace :untouched do
  desc <<-END_DESC
Checks for any issues that have been untouched for a specified time.

Options:
  :days      => Set how many days the issue needs to be untouched before triggering a reminder
  :tracker   => (Optional) Only include issues with this tracker id in the search

  END_DESC
  task :check_issues => :environment do
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']
    ReminderMailer.untouched_issue_reminder options
  end
end