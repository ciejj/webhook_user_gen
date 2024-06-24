# README

## Architectural decisions
- why rails (minimal verison, api only most o the things built in)
- why job processing (we want to process incoming webhooks really fast, so we can return status)
- business logic is present in the service file
- communication with apis has been implemented in separate classes
- tests are using vcr (extra caution with credentials) which is covering happy and failed path



TODO:
- trigger job after receiving webhook
- add test for job (simple one calling service, or not)
- add E2E test
- finish this document
