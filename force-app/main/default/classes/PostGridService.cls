public class PostGridService {
    public static void getContacts() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:Postgrid/v1/contacts');
        request.setMethod('GET');
        HttpResponse response;
        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Process the response
                System.debug('Response: ' + response.getBody());
            } else {
                System.debug('Failed with status code: ' + response.getStatusCode());
                System.debug('Response: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}
