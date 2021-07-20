## Overview
Ballerina connector for Microsoft Outlook Calendar is connecting the Calendar API in Microsoft Graph via Ballerina language easily. It provides the capability to perform CRUD (Create, Read, Update, and Delete) operations on `Event` & `Calendar` stored in Microsoft OneDrive.

This module supports the Microsoft Outlook Calendar API version 1.0.
 
## Prerequisites
Before using this connector in your Ballerina application, complete the following:
* Create a [Microsoft Outlook Account](https://outlook.live.com/owa/)
* Obtain tokens
    - Follow [this link](https://docs.microsoft.com/en-us/graph/auth-v2-user#authentication-and-authorization-steps) client ID, client secret, and refresh token.
 
## Quickstart
To use the outlook calendar connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import MS Outlook Calendar Package 
import the ballerinax/microsoft.outlook.calendar module into the Ballerina project.

```ballerina
import ballerinax/microsoft.outlook.calendar;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.

```ballerina
calendar:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};
calendar:Client calendarClient = check new(configuration);
```
### Step 3: Invoke connector operation

1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.
Following is an example on how to create a calendar using the connector.

```
public function main() returns error? {
    calendar:EventMetadata eventMetadata = {
        subject: "Test-Subject",
        body : {
            content: "Test-Body"
        },
        'start: {
            dateTime: "2021-07-16T12:00:00",
            timeZone: calendar:TIMEZONE_LK
        },
        end: {
            dateTime: "2021-07-16T14:00:00",
            timeZone: calendar:TIMEZONE_LK
        },
        location:{
            displayName:"Harry's Bar"
        },
        attendees: [{
            emailAddress: {
                address:"samanthab@contoso.onmicrosoft.com",
                name: "Samantha Booth"
            },
            'type: calendar:ATTENDEE_TYPE_REQUIRED,
            status: {
                response : calendar:RESPONSE_NOT_RESPONDED
            }
        }],
        allowNewTimeProposals: true
    };
    calendar:Event|error generatedEvent = calendarClient->createEvent(eventMetadata);
    log:printInfo(generatedEvent.toString());
}
   
```
2. Use `bal run` command to compile and run the Ballerina program.
 
**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/tree/master/samples)**
