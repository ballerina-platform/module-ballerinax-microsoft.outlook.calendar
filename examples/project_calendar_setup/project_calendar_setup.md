# Project calendar setup

This example sets up a dedicated calendar for a project. It reuses a calendar group with the given name, or creates one, adds a project calendar to that group, schedules each project milestone as an all-day event on the new calendar, and reads the calendar back, following every page of results, to confirm the schedule.

## Prerequisites

### 1. Set up a Microsoft Entra ID application

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret and refresh token. The app needs the delegated `Calendars.ReadWrite` permission.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
refreshUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
groupName = "<calendar-group-name, e.g. Projects>"
calendarName = "<project-calendar-name, e.g. Website relaunch>"
timeZone = "<time-zone, e.g. UTC>"
milestones = [
    {title = "<milestone-title, e.g. Design sign-off>", date = "<first-day, e.g. 2026-10-12>", nextDate = "<day-after, e.g. 2026-10-13>"},
    {title = "<milestone-title, e.g. Launch>", date = "<first-day, e.g. 2026-11-02>", nextDate = "<day-after, e.g. 2026-11-03>"}
]
```

All-day events in Outlook start and end at midnight, so `nextDate` is the day after the milestone.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
