public class GetContactList {
   
    public Integer skip;
    public Integer totalCount;
    public List<getContactInfo> data;

    // Inner class for contact details
    public class getContactInfo {
        public String id;
        public Boolean live;
        public String addressLine1;
        public String addressLine2;
        public String addressStatus;
        public String city;
        public String companyName;
        public String country;
        public String countryCode;
        public String description;
        public String email;
        public String firstName;
        public String jobTitle;
        public String lastName;
        public List<String> mailingLists;
        public String phoneNumber;
        public String postalOrZip;
        public String provinceOrState;
        public Boolean skipVerification;
        public Boolean forceVerifiedStatus;
        public DateTime createdAt;
        public DateTime updatedAt;
    }

 

    // Method to deserialize JSON into this object structure
    public static getContactList parse(String json) {
        return (getContactList) System.JSON.deserialize(json, getContactList.class);
    }
}