# Examples

The `ballerinax/microsoft.outlook.calendar` connector provides practical examples illustrating usage in various scenarios.

1. [Team meeting scheduler](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/tree/main/examples/team_meeting_scheduler) - Find a time when every attendee is free, book it as a Teams meeting and list the resulting schedule.
2. [Project calendar setup](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/tree/main/examples/project_calendar_setup) - Create a project calendar inside a calendar group and schedule the project milestones on it.

## Prerequisites

1. Generate Microsoft Graph credentials to authenticate the connector as described in the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-microsoft.outlook.calendar/blob/main/ballerina/README.md#setup-guide).
2. For each example, create a `Config.toml` file with the values described in that example's own guide.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
