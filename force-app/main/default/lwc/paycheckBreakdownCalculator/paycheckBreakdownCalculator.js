import { LightningElement } from 'lwc';

// Const object to store federal tax rates for 2025
const federalTaxRates = Object.freeze([
    {lowerRange: 0, upperRange: 11925, rate: 0.10},
    {lowerRange: 11925, upperRange: 48475, rate: 0.12},
    {lowerRange: 48475, upperRange: 103350, rate: 0.22},
    {lowerRange: 103350, upperRange: 197300, rate: 0.24},
    {lowerRange: 197300, upperRange: 250525, rate: 0.32},
    {lowerRange: 250525, upperRange: 626350, rate: 0.35},
    {lowerRange: 626350, upperRange: Infinity, rate: 0.37},
]);
// Initialize other constant variables
const socialSecurityTaxRate = 0.0620;
const medicareTaxRate = 0.0145;
const standardDeduction = 15000;

export default class PaycheckBreakdownCalculator extends LightningElement {
    // These values are what are shown initially on the LWC
    // Initialize salary variables connected to HTML
    grossSalary = null;  
    annualSalary = null;
    annualSalaryPercentage = null;
    sixMonthsSalary = null;
    monthlySalary = null;
    biWeeklySalary = null;
    // Initialize tax variables connected to HTML
    totalTax = null;
    totalTaxPercentage = null;
    federalIncomeTax = null;
    socialSecurityTax = null;
    medicareTax = null;
    // Hide results to start
    showResults = false;

    // Update grossSalary to input value when 'Calculate' button is clicked
    handleChange(event) {
        this.grossSalary = Number(event.target.value);
    }

    // Function that calculates all results
    calculatePaycheckBreakdown() {
        // Resets federal tax if recalculate
        this.federalIncomeTax = 0;
        // Initialize new variables just used in this function
        let federalTaxAmount = 0;
        let adjustedGrossSalary = this.grossSalary - standardDeduction;

        // Loop through each federal tax bracket to calculate the tax for necessary ranges
        for (let taxBracket of federalTaxRates) {
            if (adjustedGrossSalary > taxBracket.lowerRange) {
                federalTaxAmount = (Math.min(adjustedGrossSalary, taxBracket.upperRange) - taxBracket.lowerRange) * taxBracket.rate;
                this.federalIncomeTax += federalTaxAmount;
            }
        }

        // Update tax variables
        this.medicareTax = this.grossSalary * medicareTaxRate;
        this.socialSecurityTax = this.grossSalary * socialSecurityTaxRate;
        this.totalTax = this.federalIncomeTax + this.medicareTax + this.socialSecurityTax;
        this.totalTaxPercentage = this.totalTax / this.grossSalary;
        // Update salary variables
        this.annualSalary = this.grossSalary - this.federalIncomeTax - this.medicareTax - this.socialSecurityTax;
        this.annualSalaryPercentage = this.annualSalary / this.grossSalary;
        this.sixMonthsSalary = this.annualSalary / 2;
        this.monthlySalary = this.annualSalary / 12;
        this.biWeeklySalary = this.annualSalary / 26;
        // Show results when 'Calculate' button is clicked
        this.showResults = true;
    }
}