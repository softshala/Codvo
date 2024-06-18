public class PostgridDataController {

    public class PostgridCallout implements Queueable, Database.AllowsCallouts {
        

        public void execute(QueueableContext context) {
            HttpRequest request = buildHttpRequest('callout:Postgrid/v1/contacts');
            try {
                HttpResponse response = new Http().send(request);
                if (response.getStatusCode() == 200) {
                    handleSuccessfulResponse(response.getBody());
                } else {
                    System.debug('Error with API call: ' + response.getStatusCode() + ' ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception in Queueable callout: ' + e.getMessage());
            }
        }

        private HttpRequest buildHttpRequest(String endpointUrl) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            return request;
        }

        private void handleSuccessfulResponse(String responseBody) {
            GetContactList contactList = GetContactList.parse(responseBody);
            Postgrid_LWC_PE__e event = new Postgrid_LWC_PE__e();
            event.Response__c = JSON.serialize(contactList);
            EventBus.publish(event);
        }
    }

    @AuraEnabled
    public static void makeGetRequest() {
        System.enqueueJob(new PostgridCallout());
    }

    // The saveContacts method remains synchronous and is called directly from the LWC.
    // It should be refactored if you plan to handle bulk contact saving in a more asynchronous or batch manner.
    
    @AuraEnabled
    public static List<Contact> saveContacts(String contactListJson) {
        GetContactList contactList = GetContactList.parse(contactListJson);
        List<Contact> contactsToUpsert = prepareContactsForUpsert(contactList);
        try {
            upsert contactsToUpsert;
        } catch (DmlException e) {
            System.debug('DML exception in saveContacts: ' + e.getMessage());
            // Optionally rethrow the exception or handle it as per your error handling policy
        }
        return contactsToUpsert;
    }

    private static List<Contact> prepareContactsForUpsert(GetContactList contactList) {
        Set<String> postgridIds = new Set<String>();
        for (GetContactList.GetContactInfo contactInfo : contactList.data) {
            postgridIds.add(contactInfo.id);
        }

        Map<String, Contact> existingContactsMap = getExistingContactsMap(postgridIds);
        List<Contact> contactsToUpsert = new List<Contact>();

        for (GetContactList.GetContactInfo contactInfo : contactList.data) {
            Contact contact = existingContactsMap.get(contactInfo.id);
            if (contact == null) {
                contact = new Contact(Postgrid_Id__c = contactInfo.id);
            }
            mapFields(contactInfo, contact);
            contactsToUpsert.add(contact);
        }

        return contactsToUpsert;
    }
    
     private static Map<String, Contact> getExistingContactsMap(Set<String> postgridIds) {
        Map<String, Contact> contactsMap = new Map<String, Contact>();
        List<Contact> existingContacts = [SELECT Id, Name, Postgrid_Id__c FROM Contact WHERE Postgrid_Id__c IN :postgridIds];
        for (Contact contact : existingContacts) {
            contactsMap.put(contact.Postgrid_Id__c, contact);
        }
        return contactsMap;
    }

    private static void mapFields(GetContactList.GetContactInfo source, Contact target) {
        target.FirstName = source.firstName;
        target.LastName = source.lastName;
        target.Email = source.email;
        target.Phone = source.phoneNumber;
        target.MailingStreet = source.addressLine1;
        target.MailingCity = source.city;
        target.MailingPostalCode = source.postalOrZip;
        target.MailingCountry = source.country;
    }

}