import { LightningElement} from 'lwc';

// Const object to store federal tax rates for 2025
const federalTaxRates = [
    {lowerRange: 0, upperRange: 11925, rate: 0.10},
    {lowerRange: 11925, upperRange: 48475, rate: 0.12},
    {lowerRange: 48475, upperRange: 103350, rate: 0.22},
    {lowerRange: 103350, upperRange: 197300, rate: 0.24},
    {lowerRange: 197300, upperRange: 250525, rate: 0.32},
    {lowerRange: 250525, upperRange: 626350, rate: 0.35},
    {lowerRange: 626350, upperRange: Infinity, rate: 0.37},
];
const medicareTaxRate = 0.0145;
const socialSecurityTaxRate = 0.0620;
const standardDeduction = 15000;

export default class PaycheckBreakdownCalculator extends LightningElement {
    // Initialize salary variables connected to HTML
    grossSalary = 0;  
    annualSalary = 0;
    sixMonthsSalary = 0;
    monthlySalary = 0;
    biWeeklySalary = 0;
    // Initialize tax variables connected to HTML
    federalIncomeTax = 0;
    medicareTax = 0;
    socialSecurityTax = 0;

    // Update grossSalary to input value when 'Calculate' button is clicked
    handleChange(event) {
        this.grossSalary = Number(event.target.value);
    }

    calculatePaycheckBreakdown() {
        // Initialize new variables
        let federalTaxAmount = 0;
        let adjustedGrossSalary = this.grossSalary - standardDeduction;
        // Loop through each federal tax bracket to tax for each range
        for (const bracket of federalTaxRates) {
            if (adjustedGrossSalary > bracket.lowerRange) {
                federalTaxAmount = (Math.min(adjustedGrossSalary, bracket.upperRange) - bracket.lowerRange) * bracket.rate;
                this.federalIncomeTax += federalTaxAmount;
            }
        }

        // Update tax variables
        this.medicareTax = this.grossSalary * medicareTaxRate;
        this.socialSecurityTax = this.grossSalary * socialSecurityTaxRate;
        // Update salary variables
        this.annualSalary = this.grossSalary - this.federalIncomeTax - this.medicareTax - this.socialSecurityTax;
        this.sixMonthsSalary = this.annualSalary / 2;
        this.monthlySalary = this.annualSalary / 12;
        this.biWeeklySalary = this.annualSalary / 26;
    }
}