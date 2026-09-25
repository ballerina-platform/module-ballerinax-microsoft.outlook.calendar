## Overview

[Microsoft Outlook Calendar](https://learn.microsoft.com/en-us/graph/outlook-calendar-concept-overview) is the calendaring part of Microsoft 365. Through Microsoft Graph it exposes users' calendars, calendar groups, events, meeting responses and free/busy availability.

The Microsoft Outlook Calendar connector lets Ballerina applications manage the calendars and events of the signed-in user and of other users in the organization, respond to meeting invitations, share calendars, and find times when people are available. It supports version 1.0 of the Microsoft Graph REST API.

### Key features

- Create, read, update and delete events in the default calendar, in any calendar and in calendars grouped under a calendar group
- Accept, tentatively accept, decline, cancel and forward meetings, and dismiss or snooze their reminders
- Read calendar views and recurring-event occurrences for a time range, and track changes with delta queries
- Manage calendars and calendar groups, and share calendars by granting calendar permissions
- Suggest meeting times and check the free/busy availability of users and resources
- Add file attachments, including large files through upload sessions, and open extensions to events

## Setup guide

To use the Microsoft Outlook Calendar connector, you need a Microsoft 365 or Outlook.com account and an application registered in Microsoft Entra ID with OAuth 2.0 credentials.

### Step 1: Sign in to the Azure portal

1. If you don't have a Microsoft Azure account, you can create one for free at [https://azure.microsoft.com](https://azure.microsoft.com).

2. Go to the [Azure portal](https://portal.azure.com) and sign in. From the home page, navigate to **Microsoft Entra ID**.

   ![Azure portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/main/docs/resources/azure-portal.png)

### Step 2: Register an application

1. In the Microsoft Entra admin center, navigate to **App registrations** from the left sidebar.

   ![Entra main page](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/main/docs/resources/entra-main-page.png)

2. Click **New registration**.

3. Enter a name for the application, for example `Ballerina Outlook Calendar Connector`. Under **Supported account types**, choose the accounts that will sign in: accounts in your organization only, or any organization and personal Microsoft accounts if Outlook.com users must be able to sign in.

4. Under **Redirect URI**, select **Web** and enter the URI that receives the authorization code, for example `http://localhost`. Then click **Register**.

### Step 3: Add API permissions

1. In the registered application, navigate to **API permissions** and click **Add a permission**.

2. Select **Microsoft Graph**, then **Delegated permissions**, and add the following permissions:

   - `Calendars.ReadWrite` to read and write the signed-in user's calendars
   - `Calendars.ReadWrite.Shared` to read and write calendars that other users have shared with, or delegated to, the signed-in user (needed for the operations under `users/{userId}`)
   - `offline_access` so that the token response includes a refresh token

3. Click **Add permissions**. If your organization requires it, ask an administrator to grant consent.

### Step 4: Create a client secret

1. Navigate to **Overview** in the registered application and copy the **Application (client) ID**. This is your `clientId`.

2. Navigate to **Certificates & secrets** > **Client secrets** > **New client secret**.

   ![Add client secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/main/docs/resources/add-client-secret.png)

3. Enter a description, choose an expiry period and click **Add**. Copy the secret **Value** immediately. This is your `clientSecret`.

### Step 5: Obtain a refresh token

1. Open the following URL in a browser, replacing `<CLIENT_ID>` and `<REDIRECT_URI>` with your values, and sign in with the account whose calendar the connector will use:

   ```text
   https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=<CLIENT_ID>&response_type=code&redirect_uri=<REDIRECT_URI>&response_mode=query&scope=Calendars.ReadWrite%20Calendars.ReadWrite.Shared%20offline_access
   ```

2. After you grant consent, the browser is redirected to your redirect URI with a `code` query parameter. Copy its value.

3. Exchange the code for tokens:

   ```bash
   curl --location 'https://login.microsoftonline.com/common/oauth2/v2.0/token' \
   --header 'Content-Type: application/x-www-form-urlencoded' \
   --data-urlencode 'grant_type=authorization_code' \
   --data-urlencode 'code=<CODE>' \
   --data-urlencode 'redirect_uri=<REDIRECT_URI>' \
   --data-urlencode 'client_id=<CLIENT_ID>' \
   --data-urlencode 'client_secret=<CLIENT_SECRET>' \
   --data-urlencode 'scope=Calendars.ReadWrite Calendars.ReadWrite.Shared offline_access'
   ```

4. Store the `refresh_token` from the response securely. Use `https://login.microsoftonline.com/common/oauth2/v2.0/token` as the refresh URL. If the application is registered for your organization only, replace `common` with your tenant ID in both URLs.

## Quickstart

To use the Microsoft Outlook Calendar connector in your Ballerina application, update your `.bal` file as follows.

### Step 1: Import the module

Import the `microsoft.outlook.calendar` module.

```ballerina
import ballerinax/microsoft.outlook.calendar;
```

### Step 2: Configure the credentials

Create a `Config.toml` file with the credentials obtained in the setup guide:

```toml
clientId = "<CLIENT_ID>"
clientSecret = "<CLIENT_SECRET>"
refreshToken = "<REFRESH_TOKEN>"
refreshUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
```

### Step 3: Instantiate a new connector

Initialize the client with the refresh token grant configuration.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

final calendar:Client calendarClient = check new ({
    auth: {clientId, clientSecret, refreshToken, refreshUrl}
});
```

### Step 4: Invoke the connector operation

Use the connector operations. The following creates an event in the signed-in user's default calendar.

```ballerina
public function main() returns error? {
    calendar:Event _ = check calendarClient->createEvent({
        subject: "Project kickoff",
        'start: <calendar:DateTimeTimeZone>{dateTime: "2026-10-05T10:00:00", timeZone: "UTC"},
        end: <calendar:DateTimeTimeZone>{dateTime: "2026-10-05T11:00:00", timeZone: "UTC"}
    });
}
```

## Examples

The Microsoft Outlook Calendar connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/tree/main/examples/), covering the following use cases:

1. [Team meeting scheduler](../examples/team_meeting_scheduler/team_meeting_scheduler.md) - Find a time when every attendee is free, book it as a Teams meeting and list the resulting schedule.
2. [Project calendar setup](../examples/project_calendar_setup/project_calendar_setup.md) - Create a project calendar inside a calendar group and schedule the project milestones on it.
