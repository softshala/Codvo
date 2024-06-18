public class DataComponentController {
    @AuraEnabled
    public static Contact contactMethod(Map<String, String> contactData) {
        System.debug(contactData);
        Contact con = new Contact();
        con.FirstName = contactData.get('Firstname');
        con.LastName = contactData.get('Lastname');
        con.Birthdate = Date.valueOf(contactData.get('DOB'));
        con.Email = contactData.get('Email');
        con.Phone = contactData.get('Phone');
        insert con;
        return con;
    }
}
