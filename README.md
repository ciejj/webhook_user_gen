# README

## Architectural decisions

The decision to utilize Ruby on Rails for this project was guided by its suitability for developing API-centric applications. 
It comes with ActiveJob framework, allowing to manage webhooks in the background without any other dependencies (such as Sidekiq, or Redis).
Minitest is also in place allowing to test the whole process wihtout many additional dependencies (`mocha`, `VCR`, `webmock`)
SQLite has been selected for this project due to its simplicity and lightness which match the needs of straightforward read/write operations.

## Application flow
- `/webhooks` endpoint receives request

### WebhookController
- It processes the incoming request, and performs verification (which currently is simple parameter check)
- Payload is saved in `ReceivedWebhook` object, and `WebhookHandlerJob` is scheduled with that object.
- `ReceivedWebhook` is a helper object, that helps with tracking of received request, and their processing results and errors
- There is a simple check in place allowing to avoid processing exactly the same payloads
- It returns `head :ok` after the scheduling job, or `head :bad_request` if verification fails

### WebhookHandlerJob
- It checks the payload, if the event type is known (in our case we have only one type of it `application_hired`), and if it has all necessary data in it
- If the payload is valid it calls the `Services::HireApplicant` service
- After the service finishes, the JobHandler updates the `ReceivedWebhook` object with errors, result, and execution_details

### HireApplicant Service
- This class holds all the business logic of our process
- It gets application details from Pinpont, creates Employee at HiBob, and then uploads cv, and adds comment to Pinpoints application
- To communicate with external APIs with the help of wrapper classes: `ApiClients::HiBob::Client`, and `ApiClients::Pinpoint::Client`
- Those clases are encapsulating API related information, such as validation, and parsing of received responses

### Tests
- There is an integration test covering happy path of the whole process. It is using `VCR` for handling external calls
- `HireApplicant` Service is covered with specs also using `VCR` covering various scenarios of successful, and failing external calls
- `WebhookHandlerJob` is tested for parsing incoming payload, and checking if it has all requeired information. It is using mocked services to avoid making external calls
- `WebhookController` is tested for processing of incoming requests, and queing them for processing
