_Author_:  @DimuthuMadushan \
_Created_: 2026/09/25 \
_Updated_: 2026/09/25 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Microsoft Outlook Calendar.
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/microsoft/graph/v1.0/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Extract the Outlook calendar subset of Microsoft Graph v1.0
- **Original**: The Microsoft Graph v1.0 description covers the whole Graph API (about 44 MB).
- **Updated**: `docs/spec/openapi.yaml` is produced by `docs/resources/script.py`. It keeps every path whose first segment under `/me/` or `/users/{user-id}/` is `calendar`, `calendars`, `calendarGroups`, `calendarView`, `events` or `findMeetingTimes` (250 paths, 352 operations), copied verbatim in upstream order, plus the transitive `$ref` closure of those paths in `components`. Group calendars (`/groups/{group-id}/calendar...`) are out of scope.
- **Reason**: The connector covers the Outlook calendar surface only. Re-run `python3 docs/resources/script.py` to rebuild the subset from the source.

2. Add the OAuth 2.0 security scheme
- **Original**: The extracted subset has no `securitySchemes` and no top-level `security`.
- **Updated**: Added an `oAuth2` scheme with the `authorizationCode` flow (`https://login.microsoftonline.com/common/oauth2/v2.0/authorize` and `.../token`, with `Calendars.*` and `offline_access` scopes) and a top-level `security` requirement on it, in `docs/spec/openapi.yaml`.
- **Reason**: Without a security scheme the generated client has no `auth` configuration. Microsoft Graph calendar APIs take a Microsoft identity platform access token.

3. Strip the `dollar` prefix from OData query parameter names
- **Original**: `align` names the OData query parameters `dollarSelect`, `dollarExpand`, `dollarOrderby`, `dollarTop`, `dollarSkip`, `dollarCount`, `dollarFilter` and `dollarSearch` through `x-ballerina-name`.
- **Updated**: The `x-ballerina-name` values are `select`, `expand`, `orderby`, `top`, `skip`, `count`, `filter` and `search` (325 parameters). Ballerina 2201.13.4 quotes the keyword `select` itself.
- **Reason**: Readable parameter names. The wire names (`$select`, ...) are unchanged.

4. Name the `findMeetingTimes` request body
- **Original**: `components.requestBodies.findMeetingTimesRequestBody` declared an inline object schema.
- **Updated**: The schema is moved to `components.schemas.FindMeetingTimesRequest`, with a description on each property, and the request body refers to it.
- **Reason**: An inline object generates an anonymous record in the method signature.

5. Simplify the `findMeetingTimes` response
- **Original**: `components.responses.findMeetingTimesResponse` was `anyOf: [MeetingTimeSuggestionsResult, {type: object, nullable: true}]`.
- **Updated**: The response schema is `$ref: MeetingTimeSuggestionsResult`.
- **Reason**: The union generated a public `inline_response_2XX` type. The action always returns a `meetingTimeSuggestionsResult`.

6. Simplify the `createUploadSession` response
- **Original**: The eight `.../attachments/createUploadSession` operations returned the flatten-generated `InlineResponse2XX` (`anyOf: [UploadSession, {type: object, nullable: true}]`).
- **Updated**: They return `$ref: UploadSession`; the wrapper schema and its empty `anyOf` member are removed.
- **Reason**: The action always returns an `uploadSession`, and the wrapper added two public types with no meaning.

7. Simplify the `daysOfWeek` items
- **Original**: `RecurrencePattern.daysOfWeek` and `WorkingHours.daysOfWeek` items were flatten-generated wrappers of `anyOf: [DayOfWeek, {type: object, nullable: true}]`.
- **Updated**: The items are `$ref: DayOfWeek`; the four wrapper schemas are removed.
- **Reason**: Days of the week are always one of the `DayOfWeek` values.

8. Rewrite operation summaries
- **Original**: The Graph summaries are derived from navigation properties and repeat across scopes (for example, 36 operations read "Get the number of the resource" and 24 read "Invoke function delta").
- **Updated**: Every operation summary is written from its path, naming the action, the resource and its scope, for example "List the events in a calendar of a calendar group of a user". All 352 summaries are distinct.
- **Reason**: The summaries become the method documentation, and duplicates made operations indistinguishable.

9. Add missing descriptions
- **Original**: 79 schema properties (such as the `@odata.type`, `value` and action-parameter fields), 68 schemas, the 36 `If-Match` headers and the 62 action request bodies ("Action parameters") had no usable description.
- **Updated**: Each of them has a concise description.
- **Reason**: Undocumented fields and parameters generate undocumented Ballerina symbols.

10. Make `@odata.type` optional and remove the entity discriminator
- **Original**: `align` marks `@odata.type` as required in 40 schemas, and `microsoft.graph.entity` carries a `discriminator` whose 1,207 mapping entries point at schemas outside the subset.
- **Updated**: `@odata.type` is removed from every `required` list, and the dangling discriminator is removed.
- **Reason**: Microsoft Graph omits `@odata.type` from most responses, so a required field fails response binding. Applied by `tooling/sanitize_spec.py`.

11. Replace the navigation-property boilerplate and generic `Success` descriptions
- **Original**: Summaries, request bodies and responses read "New navigation property", "Update the navigation property ... in me" or "Retrieved navigation property", and 74 responses with a body were described only as "Success".
- **Updated**: They describe the resource and the returned entity. Responses without a body keep "Success".
- **Reason**: Readable method and return documentation. Applied by `tooling/sanitize_spec.py`.

12. Operation and schema names
- **Original**: Graph operationIds such as `me.calendar.events.ListAttachments` and schema names such as `microsoft.graph.event`.
- **Updated**: camelCase operationIds (`listDefaultEventAttachments`, ...) with the scope in the name (`User` for `/users/{userId}`, `Default` for the default calendar, `Calendar` for a calendar by ID, `Group` for a calendar in a calendar group), and schema names without the `MicrosoftGraph` prefix. The 2.4.0 method names `listEvents`, `getEvent`, `createEvent`, `updateEvent`, `deleteEvent`, `listCalendars`, `getCalendar`, `createCalendar`, `updateCalendar` and `deleteCalendar` are kept for the same `/me` operations. The decisions are recorded in `docs/spec/ai-mappings.json`.
- **Reason**: Stable, readable method and type names across regenerations.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --license docs/license.txt --client-methods remote
```

Note: The license year is hardcoded to 2026, change if necessary.
