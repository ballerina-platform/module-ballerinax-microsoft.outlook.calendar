# Change Log

This file contains all the notable changes done to the Ballerina Microsoft Outlook Calendar connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The connector now covers the Microsoft Graph v1.0 calendar surface: 352 operations over calendars, calendar
  groups, calendar permissions, events, event attachments and open extensions, calendar views, recurring-event
  instances, delta queries, meeting responses, free/busy schedules and meeting-time suggestions, for both the
  signed-in user (`/me`) and a user by ID (`/users/{userId}`).

### Changed

- The client is now generated from the Microsoft Graph OpenAPI description. The ten operations carried over from
  2.4.0 keep their names but have new signatures, and every record type is replaced by the Microsoft Graph type of
  the same resource (`Event`, `Calendar`, `Attendee`, `DateTimeTimeZone`, ...). `EventMetadata` and
  `CalendarMetadata` are replaced by `Event` and `Calendar`, the `TimeZone` / `ContentType` enums and the
  `string? queryParams` argument are replaced by typed OData query parameters (`top`, `skip`, `filter`,
  `orderby`, `'select`, `expand`, ...), and the `Prefer` header options are passed through `headers`.
- `listEvents` and `listCalendars` now return one page (`EventCollection` / `CalendarCollection`, with
  `atOdataNextLink`) instead of a `stream`.
- `createEvent` and `updateEvent` no longer take an optional `calendarId`; they act on the signed-in user's
  events. Use `createCalendarEvent` / `updateCalendarEvent` for an event in a specific calendar.
- `updateCalendar` takes a `Calendar` payload instead of the separate `name`, `color` and `isDefaultCalendar`
  arguments.
- `init` takes an optional `serviceUrl` (default `https://graph.microsoft.com/v1.0`), and the connection
  configuration accepts either a bearer token or the refresh token grant.
- The minimum Ballerina distribution is now **2201.13.4** (Swan Lake Update 13).

| 2.4.0 method | 3.0.0 method |
|---|---|
| `listEvents(timeZone, contentType, queryParams)` returns `stream<Event, error?>` | `listEvents(headers, top = ..., filter = ..., ...)` returns `EventCollection` |
| `getEvent(eventId, timeZone, contentType, queryParams)` | `getEvent(eventId, headers, 'select = ..., expand = ...)` |
| `createEvent(EventMetadata, calendarId?)` | `createEvent(Event)`, or `createCalendarEvent(calendarId, Event)` |
| `updateEvent(eventId, EventMetadata, calendarId?)` | `updateEvent(eventId, Event)`, or `updateCalendarEvent(calendarId, eventId, Event)` |
| `deleteEvent(eventId)` | `deleteEvent(eventId, headers)` |
| `listCalendars(queryParams)` returns `stream<Calendar, error?>` | `listCalendars(headers, top = ..., filter = ..., ...)` returns `CalendarCollection` |
| `getCalendar(calendarId, queryParams)` | `getCalendar(calendarId, headers, 'select = ..., expand = ...)` |
| `createCalendar(CalendarMetadata)` | `createCalendar(Calendar)` |
| `updateCalendar(calendarId, name?, color?, isDefaultCalendar?)` | `updateCalendar(calendarId, Calendar)` |
| `deleteCalendar(calendarId)` | `deleteCalendar(calendarId, headers)` |

### Removed

- `addQuickEvent` is removed and has no replacement. Call `createEvent` with only a subject instead, for example
  `check calendarClient->createEvent({subject: "Lunch"})`, or `createCalendarEvent` to add it to a specific
  calendar.
- The `EventMetadata`, `CalendarMetadata`, `GeneratedEventData` and `GeneratedCalendarData` records and the
  `TimeZone`, `ContentType` and `ShowAs` enums are removed. Use `Event`, `Calendar`, `BodyType` and
  `FreeBusyStatus`; time zones are plain strings in `DateTimeTimeZone.timeZone`.
- The remaining 2.4.0 enums (`AttendeeType`, `ResponseType`, `Importance`, ...) are now string-literal union types,
  so enum members such as `calendar:ATTENDEE_TYPE_REQUIRED` are replaced by string values such as `"required"`.
  `RecurrencePattern` is now the Graph record that describes a recurrence; its former members are the values of
  `RecurrencePatternType`.
