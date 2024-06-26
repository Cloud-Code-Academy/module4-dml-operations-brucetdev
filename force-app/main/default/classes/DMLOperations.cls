/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Bruce Harpham
 */


public with sharing class DMLOperations {

     /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
          
        // Create a new Account instance
        Account acc = new Account();
        // Set some fields on the Account
        acc.Name = 'IBM';
        acc.NumberOfEmployees = 282200;
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
        }

       /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
     Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.LastName = 'Simmons';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];

        // Update the Contact's last name
        contact.LastName = newLastName;
        // Update the Contact in the database
        update contact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
       
        // Update the Opportunity's stage
        opp.StageName = newStage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        acc.name = newName; acc.Industry = newIndustry;
        update acc;
    }


    /**
 * Question 7 -- PASSED!
 * Create or update Opportunities.
 * The Opportunity's Stage is set to Qualification.
 * The Opportunity's Close Date is set to 3 months from today.
 * The Opportunity's Amount is set to 50000.
 * @param opportunities List of Opportunities to be changed then upserted.
 */
public static void upsertOpportunityList(List<Opportunity> opportunities) {
    Date threeMonthsFromToday = Date.today().addMonths(3);
    for (Opportunity opp : opportunities) {
        opp.StageName = 'Qualification';
        opp.CloseDate = threeMonthsFromToday;
        opp.Amount = 50000;
    }
    // Upsert the list of opportunities so that records are either updated or created
    upsert opportunities;
}

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Query the Account with the provided name
        List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        
        Account acc;
        
        if (!accList.isEmpty()) {
            // Account with the given name exists, use it
            acc = accList[0];
        } else {
            // Account with the given name doesn't exist, create a new one
            acc = new Account(Name = accountName);
            insert acc;
        }
    
        // Retrieve existing Opportunities related to the Account
        List<Opportunity> existingOpps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :acc.Id];
    
        // Create a map to store existing Opportunity names
        Map<String, Opportunity> existingOppsMap = new Map<String, Opportunity>();
        for (Opportunity opp : existingOpps) {
            existingOppsMap.put(opp.Name, opp);
        }
    
        // Create a list to store Opportunity records for upsert
        List<Opportunity> opportunities = new List<Opportunity>();
    
        // Loop through each Opportunity name
        for (String oppName : oppNames) {
            // Check if an Opportunity with the same name already exists
            if (existingOppsMap.containsKey(oppName)) {
                // If exists, update the existing Opportunity
                Opportunity existingOpp = existingOppsMap.get(oppName);
                existingOpp.StageName ='Prospecting';
                existingOpp.CloseDate = Date.today().addDays(30);
                opportunities.add(existingOpp);
            } else {
                // If not exists, create a new Opportunity and associate it with the Account
                Opportunity newOpp = new Opportunity(
                    Name = oppName,
                    AccountId = acc.Id,
                    StageName ='Prospecting',
                    CloseDate = Date.today().addDays(30)
                );
                opportunities.add(newOpp);
            }
        }
    
        // Perform upsert operation on the list of Opportunities
        upsert opportunities;
    
        // Validate that the number of updated and newly inserted Opportunities matches the number of Opportunity names provided
        System.assertEquals(oppNames.size(), opportunities.size(), 'The number of upserted Opportunities should match the number of Opportunity names provided');
    }
    
    

    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
    public static Account upsertAccount(String accountName) {
        // Query for the Account
        List<Account> accounts = [SELECT Id, Name, Description FROM Account WHERE Name = :accountName ];
    
        if (!accounts.isEmpty()) {
            // If the account exists, update its description
            for (Account acc : accounts) {
                acc.Description = 'Updated Account';
            }
        } else {
            // If the account doesn't exist, create a new one
            Account newAccount = new Account(Name = accountName, Description = 'New Account');
            accounts.add(newAccount);
        }
    
        // Upsert the Account
        upsert accounts;
    
        // Return the first (or newly created) account
        return accounts.isEmpty() ? null : accounts[0];
    }
    

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
    public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        // Loop through each Contact
        for (Contact con : contactsToUpsert) {
            // Extract the Account Name from Contact's LastName
            String accountName = con.LastName;
            
            // Get the account based on the name or create one if it doesn't exist
            Account acc = upsertAccount(accountName);
            
            // Link the Contact to its Account using the Account Id
            if (acc != null) {
                con.AccountId = acc.Id;
            }
        }
        
        // Upsert the Contacts
        upsert contactsToUpsert;
    }
    


    /**
     * Question 11 - PASSED
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsToInsert = new List<Lead>();
        
        // Loop through each Lead name
        for (String leadName : leadNames) {
            // Create a Lead record with the provided name
            Lead newLead = new Lead(
                LastName = leadName,
                Company = 'Sample Company' // Example company name, modify as needed
            );
            leadsToInsert.add(newLead);
        }
        
        // Insert the Lead records
        insert leadsToInsert;
        
        // Delete the Lead records
        delete leadsToInsert;
    }
    

    /**
     * Question 12 - SOLVED!
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToInsert = new List<Case>(); // Corrected the syntax error here
        // Insert the cases
        for (Integer i = 0; i < numOfCases; i++){
            Case newCase = new Case(
                AccountId = accountId,
                Subject = 'Test Case ' + (i +1),
                Description = 'Description for Test Case ' + (i +1)
            );
            casesToInsert.add(newCase);
        }
        insert casesToInsert;
        // Delete the cases
        delete casesToInsert;
    }
}