# Team meeting scheduler

This example asks Outlook for meeting times when every attendee is free inside a time window, books the best suggestion as a Microsoft Teams meeting, and then lists everything on the signed-in user's calendar in that window so the new meeting can be seen alongside the rest of the schedule.

## Prerequisites

### 1. Set up a Microsoft Entra ID application

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret and refresh token. The app needs the delegated `Calendars.ReadWrite` permission. Finding times for other attendees also needs their free/busy information to be visible to the signed-in user, which is the default inside one Microsoft 365 organization.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
refreshUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
attendeeEmails = ["<attendee-email-1>", "<attendee-email-2>"]
meetingSubject = "<meeting-subject>"
windowStart = "<window-start, e.g. 2026-10-05T09:00:00>"
windowEnd = "<window-end, e.g. 2026-10-09T17:00:00>"
timeZone = "<time-zone, e.g. UTC or Pacific Standard Time>"
meetingDuration = "PT30M"
sendInvitations = false
```

Creating the meeting sends an invitation to every attendee, so the example only books the slot when `sendInvitations` is `true`. Otherwise it prints the slot it would book.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
