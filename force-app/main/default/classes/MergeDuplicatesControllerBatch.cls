public class MergeDuplicatesControllerBatch implements Database.Batchable<childRelationship> {
    
    public List<childRelationship> childRecord;
    public String oldRecordId;
    public String newRecordId;
    public String objectName;
    
    public MergeDuplicatesControllerBatch(List<childRelationship> childRelation, String oldRecordId,String newRecordId,String objectName){
        this.childRecord = childRelation;
        this.oldRecordId = oldRecordId;
        this.newRecordId = newRecordId;
        this.objectName = objectName;
    }
    
    // Query all accounts that need updating
    public Iterable<childRelationship> start(Database.BatchableContext BC) {
        return childRecord;
    }
    
    // Process each batch of records
    public void execute(Database.BatchableContext BC, List<childRelationship> scope) {
        String childObjectName = scope[0].objectName; // Child object API name
        String parentField = scope[0].parentField; // Field API name that links child to parent
        
        // Query to fetch child records linked to the old parent
        String query = 'SELECT Id, ' + parentField + ' FROM ' + childObjectName + ' WHERE ' + parentField + ' = :oldRecordId';
        List<SObject> children = Database.query(query);
        // Update each child record to point to the new parent
        for (SObject child : children) {
            child.put(parentField, newRecordId);
        }
        
        // Perform the update on all fetched children
        update children;
    }
    
    // Execute any post-processing operations
    public void finish(Database.BatchableContext BC) {
        //Retrieve record to record
        sObject deleteRecord = MergeDuplicatesController.querySingleRecord(objectName,oldRecordId,new List<String>{'id'});
        
        //delete merged record
        delete deleteRecord;
    }
}