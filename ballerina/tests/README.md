# Running Tests

The test suite covers the core calendar workflows of the connector: listing, creating, reading, updating and deleting events, calendars and calendar groups; reading the calendar view and the occurrences of a recurring event; responding to, cancelling and forwarding meetings; adding, listing and deleting event attachments; finding meeting times; reading free/busy schedules; and listing another user's events.

## Prerequisites

To run the tests against the live Microsoft Graph API you need an application registered in Microsoft Entra ID, its client ID and client secret, and a refresh token with the `Calendars.ReadWrite`, `Calendars.ReadWrite.Shared` and `offline_access` permissions. Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/blob/main/ballerina/README.md#setup-guide) to obtain them.

## Test environments

There are two test environments. The default is a mock server for the Outlook calendar API. The other is the live Microsoft Graph API.

 Test Groups | Environment
-------------|------------------------------------------------
 mock_tests  | Mock server for the Outlook calendar API (default)
 live_tests  | Microsoft Graph API

## Running tests against the mock server

No configuration is needed. When `IS_LIVE_SERVER` is not set to `true`, the tests run against the mock server on port `9090`.

```bash
./gradlew clean test
```

## Running tests against the live Microsoft Graph API

Set the following environment variables, then run the tests.

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to target `https://graph.microsoft.com/v1.0` instead of the mock server |
| `OUTLOOK_CLIENT_ID` | Application (client) ID |
| `OUTLOOK_CLIENT_SECRET` | Client secret of the application |
| `OUTLOOK_REFRESH_TOKEN` | OAuth 2.0 refresh token of the test account |
| `OUTLOOK_USER_ID` | ID or user principal name of a user whose calendar is shared with the test account |
| `OUTLOOK_ATTENDEE_EMAIL` | Email address invited to, and forwarded, the test meetings |

```bash
export IS_LIVE_SERVER=true
export OUTLOOK_CLIENT_ID=<your-client-id>
# ... and the remaining variables above
./gradlew clean test -Pgroups=live_tests
```

The create, update and delete tests change data in the test account's calendar and send meeting invitations to `OUTLOOK_ATTENDEE_EMAIL`. Each delete test creates the event, calendar, calendar group or attachment it deletes, so no existing data is removed. Accepting and declining a meeting needs an invitation organised by someone else, so `testAcceptEvent` and `testDeclineEvent` run against the mock server only.
