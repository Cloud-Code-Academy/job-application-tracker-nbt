import { LightningElement } from 'lwc';

export default class PaycheckBreakdownCalculator extends LightningElement {
    // Gross Salary
    grossSalary = 0;   
    // Annual Salary
    annualSalary = 0;
    // 6 Months Salary
    sixMonthsSalary = 0;
    // Monthly Salary
    monthlySalary = 0;
    // Bi-Weekly Salary
    biWeeklySalary = 0;
    // Federal Tax
    federalTax = 0;
    // Medicare Tax
    medicareTax = 0;
    // Social Security Tax
    socialSecurityTax = 0;

    calculateAnnualSalary() {
        this.annualSalary = this.grossSalary - this.federalTax - this.medicareTax - this.socialSecurityTax;
    }
}