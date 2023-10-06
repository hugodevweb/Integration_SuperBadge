@isTest
public class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse and set the status code to simulate a callout failure (e.g., 500 Internal Server Error).
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(500); // Simulating a callout failure with a 500 status code
        res.setStatus('Internal Server Error');
        res.setBody('{"message": "Callout failed"}'); // You can set an error message here if needed

        return res;
    }
}