# Netguru Toggl notifier

Application sends notifications about working hours basing on toggl reports.

Daily notifications are sent to users who exceed their total working time (8h/day) during the week.
Notification is not sent when overtime is less than 10 minutes.

Weekly report is sent to office on monday and it contains list of these users who worked longer than 40 hours in the previous week.

Monthly report looks for invalid entries (too long dinner, entry without a project) and sends to users lists of them.

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

Sending monthly reports
```
bin/rake send_monthly - for current year and month
bin/rake send_monthly[2016,4] - for specific year and month
bin/rake send_monthly[2016,4,true] - force resending for specific year and month
```

Developer console:

```
bin/rake console
```

### Environment vairables
```
APP_ENV - application environment
COMPANY_NAME - company name (Toggl workspace name)
OFFICE_EMAIL - sender of all reports, recipient of weekly reports
TOGGL_TOKEN - Toggl API token
DATABASE_URL - database connection data (for example `postgres://ng-toggl-notifier@localhost/ng-toggl-notifier`)
SENDGRID_USERNAME - SendGrid user name
SENDGRID_PASSWORD - SendGrid user password
SEND_WEEKLY_EVERY_DAY - used for testing
TEST_EMAIL (optional) - used for testing, send all emails to this email account
```

### Testing
```
bin/rspec
```
