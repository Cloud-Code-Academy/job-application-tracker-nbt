public with sharing class JobApplicationSalaryHelper {
    // Constants
    private static final Decimal MEDICARE_TAX_RATE = 0.0145;
    private static final Decimal SOCIAL_SECURITY_TAX_RATE = 0.0620;
    private static final Decimal STANDARD_DEDUCTION = 15000.00;
    private static final Double INFINITY = 1.7976931348623157 * Math.pow(10, 308);

    // Tax bracket class
    private class TaxBracket {
        public Decimal lowerBound;
        public Decimal upperBound;
        public Decimal rate;
        
        // Constructor
        public TaxBracket(Decimal lowerBound, Decimal upperBound, Decimal rate) {
            this.lowerBound = lowerBound;
            this.upperBound = upperBound;
            this.rate = rate;
        }
    }

    // Tax brackets
    private static final List<TaxBracket> TAX_BRACKETS = new List<TaxBracket>{
        new TaxBracket(0, 11925, 0.10),
        new TaxBracket(11925, 48475, 0.12),
        new TaxBracket(48475, 103350, 0.22),
        new TaxBracket(103350, 197300, 0.24),
        new TaxBracket(197300, 250525, 0.32),
        new TaxBracket(250525, 626350, 0.35),
        new TaxBracket(626350, INFINITY, 0.37)
    };

    private static Decimal calculateFederalTax(Decimal grossSalary) {
        // Apply standard deduction
        Decimal adjustedSalary = Math.max(0, grossSalary - STANDARD_DEDUCTION);
        // Initialize federalTaxAmount
        Decimal federalTaxAmount = 0;
        
        // Loop through each federal tax bracket in the list to calculate the tax for necessary ranges
        for (TaxBracket bracket : TAX_BRACKETS) {
            if (adjustedSalary > bracket.lowerBound) {
                federalTaxAmount += ((Math.min(adjustedSalary, bracket.upperBound) - bracket.lowerBound) * bracket.rate);
            }
        }
        return federalTaxAmount;
    }

    private static void calculateTaxesAndNetSalary(Job_Application__c jobApp) {
        // Return error is salary is negative
        if (jobApp.Salary__c < 0) {
            jobApp.Salary__c.addError('Salary cannot be negative.');
            return;
        }

        // Calculate all taxes
        jobApp.Medicare_Tax__c = jobApp.Salary__c * MEDICARE_TAX_RATE;
        jobApp.Social_Security_Tax__c = jobApp.Salary__c * SOCIAL_SECURITY_TAX_RATE;
        jobApp.Federal_Income_Tax__c = calculateFederalTax(jobApp.Salary__c);
        
        // Calculate net salary
        jobApp.Net_Salary__c = jobApp.Salary__c - jobApp.Federal_Income_Tax__c - jobApp.Medicare_Tax__c - jobApp.Social_Security_Tax__c;
    }

    public static void calculateSalaryAndTaxOnInsert(List<Job_Application__c> newJobApps) {      
        for (Job_Application__c jobApp : newJobApps) {
            // Only calculate if salary is provided
            if (jobApp.Salary__c != null) {
                calculateTaxesAndNetSalary(jobApp);
            }
        }
    }

    public static void calculateSalaryAndTaxOnUpdate(List<Job_Application__c> newJobApps, Map<Id, Job_Application__c> oldJobAppsMap) {
        for (Job_Application__c jobApp : newJobApps) {
            // Only recalculate if salary or other related field is changed
            if (jobApp.Salary__c != oldJobAppsMap.get(jobApp.Id).Salary__c || 
                jobApp.Medicare_Tax__c == oldJobAppsMap.get(jobApp.Id).Medicare_Tax__c ||
                jobApp.Social_Security_Tax__c == oldJobAppsMap.get(jobApp.Id).Social_Security_Tax__c ||
                jobApp.Federal_Income_Tax__c == oldJobAppsMap.get(jobApp.Id).Federal_Income_Tax__c ||
                jobApp.Net_Salary__c == oldJobAppsMap.get(jobApp.Id).Net_Salary__c) {
                calculateTaxesAndNetSalary(jobApp);
            }
        }
    }
}