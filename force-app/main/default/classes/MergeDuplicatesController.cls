public with sharing class MergeDuplicatesController {
    
    // Method to retrieve all child relationships for a given SObject
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getChildRelationships(String objectName) {
        try {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType parentType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult parentDescribe = parentType.getDescribe();
            
            List<Map<String, String>> childRelations = new List<Map<String, String>>();
            for (Schema.ChildRelationship relation : parentDescribe.getChildRelationships()) {
                if(relation.getChildSObject().getDescribe().getName().endswith('__c')){
                    Map<String, String> relationInfo = new Map<String, String>();
                    relationInfo.put('childObject', relation.getChildSObject().getDescribe().getName());
                    relationInfo.put('field', relation.getField().getDescribe().getName());
                    childRelations.add(relationInfo);
                }
            }
            return childRelations;
        } catch (Exception e) {
            // Log exception and return an empty list if an error occurs
            System.debug('Error retrieving child relationships: ' + e.getMessage());
            return new List<Map<String, String>>();
        }
    }
    
    // Method to get detailed record information by object name and record ID
    @AuraEnabled(cacheable=true)
    public static SObject getRecordDetails(String objectName, String recordId) {
        try {
            List<String> fieldsToQuery = getAllFields(objectName); // Use existing method to get all fields
            return querySingleRecord(objectName, recordId, fieldsToQuery);
        } catch (Exception e) {
            System.debug('Error getting record details: ' + e.getMessage());
            return null; // Return null on failure
        }
    }
    
    // Method to merge selected fields from one record to another
    @AuraEnabled
    public static void mergeSelectedFields(String baseRecordId, String mergeRecordId, String objectName, Map<String, String> fieldSelection) {
        try {
            // Retrieve fields for both records
            List<String> masterFields = new List<String>(fieldSelection.keySet());
            List<String> mergeFields = new List<String>(fieldSelection.values());
            
            // Prepare queries to get both records
            SObject baseRecord = querySingleRecord(objectName, baseRecordId, masterFields);
            SObject mergeRecord = querySingleRecord(objectName, mergeRecordId, mergeFields);
            
            // Iterate over the field selection map to set the selected fields from merge record to master record
            for (String masterField : fieldSelection.keySet()) {
                String mergeField = fieldSelection.get(masterField);
                baseRecord.put(masterField, mergeRecord.get(mergeField)); // Set field from merge to master
            }
            
            update baseRecord; // Update the master record with merged data
            reparentChildRecords(mergeRecordId, baseRecordId, objectName); // Reparent child records
            
            // Optionally delete the merge record
            delete mergeRecord;
        } catch (Exception e) {
            System.debug('Error merging fields: ' + e.getMessage());
            // Handle error (e.g., logging, notifying users)
        }
    }
    
    // Method to retrieve metadata of all fields for a given SObject
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFieldMetadata(String objectName) {
        try {
            List<Map<String, String>> fields = new List<Map<String, String>>();
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType objectType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            
            for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                if (fieldDesc.isUpdateable() && fieldDesc.isAccessible()) {
                    Map<String, String> fieldInfo = new Map<String, String>();
                    fieldInfo.put('apiName', fieldDesc.getName());
                    fieldInfo.put('label', fieldDesc.getLabel());
                    fieldInfo.put('type', String.valueOf(fieldDesc.getType()).toLowerCase());
                    fields.add(fieldInfo);
                }
            }
            return fields;
        } catch (Exception e) {
            System.debug('Error retrieving field metadata: ' + e.getMessage());
            return new List<Map<String, String>>(); // Return empty list on failure
        }
    }
    
    // Utility method to perform a dynamic SOQL query based on object name, record ID, and a list of fields
    public static SObject querySingleRecord(String objectName, String recordId, List<String> fieldsToQuery) {
        try {
            String queryString = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
            return Database.query(queryString);
        } catch (Exception e) {
            System.debug('Error querying single record: ' + e.getMessage());
            return null; // Return null on failure
        }
    }
    
    // Method to identify duplicate records based on name and custom email field
    @AuraEnabled(cacheable=true)
    public static List<SObject> findDuplicates(String currentRecordId, String objectName) {
        try {
            List<String> fieldsToQuery = getAllFields(objectName);
            SObject baseRecord = querySingleRecord(objectName, currentRecordId, fieldsToQuery);
            String name = (String)baseRecord.get('Name');
            String email = (String)baseRecord.get('Email__c');
            
            String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM ' + objectName + 
                ' WHERE Name = :name AND Email__c = :email AND Id != :currentRecordId';
            return Database.query(query);
        } catch (Exception e) {
            System.debug('Error finding duplicates: ' + e.getMessage());
            return new List<SObject>(); // Return empty list on failure
        }
    }
    
    // Internal method to reparent child records from one record to another
    private static void reparentChildRecords(String oldParentId, String newParentId, String objectName) {
        try {
            List<Map<String, String>> childRelations = getChildRelationships(objectName);
            List<childRelationship> childList = new List<childRelationship>();
            for (Map<String, String> relation : childRelations) {
                childRelationship singleRecord = new childRelationship();
                singleRecord.objectName = relation.get('childObject');
                singleRecord.parentField = relation.get('field');
                childList.add(singleRecord);
            }
            database.executeBatch(new MergeDuplicatesControllerBatch(childList, oldParentId, newParentId, objectName), 1);
        } catch (Exception e) {
            System.debug('Error reparenting child records: ' + e.getMessage());
        }
    }
}
