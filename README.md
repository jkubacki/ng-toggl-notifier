# Netguru Toggl notifier

Application sends notifications about working hours basing on toggl reports.
Daily reports are sent to users when they worked longer than 8 hours/day. Weekly report is sent to office on monday and it contains list of these users who worked longer than 40 hours in the previous week.

### Usage

Running migrations:
```
bin/rake db:migrate
```

Sending daily reports:
```
bin/rake send_daily
```

Sending to office weekly reports:
```
bin/rake send_weekly
```

### Environment vairables
```
APP_ENV - application environment
COMPANY_NAME - company name (Toggl workspace name)
OFFICE_EMAIL - sender of all reports, recipient of weekly reports
TOGGL_TOKEN - Toggl API token
SEND_WEEKLY_EVERY_DAY - used for testing
DATABASE_URL - database connection data
SENDGRID_USERNAME - SendGrid user name
SENDGRID_PASSWORD - SendGrid user password

```

### Testing
```
bin/rake
```
