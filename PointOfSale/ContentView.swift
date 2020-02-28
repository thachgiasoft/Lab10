import SwiftUI

/**
 * ContentView.swift
 *  TipCalculator View Controller to handle Components and their state
 *
 * @author Bryan Copeland
 * @since 2020-02-20
 */
struct ContentView : View {
    
    /* **************************************** */
    /* Globals (instance variables & constants) */
    @State
    private var totalInput: Double? = 18.94
    
    @State
    private var selectedTipPercentage = 1
    
    @State
    private var selectedTaxPercentage = 1
    
    // common tip ranges
    private let tipPercentages = [0, 0.05, 0.10, 0.15, 0.2, 0.25]
    // province list
    private let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "ON", "PE", "QC", "SK", "NU", "NT", "YK"]
    // provincial tax rates
    private let taxPercentages = [0.05, 0.05, 0.05, 0.15, 0.15, 0.05, 0.15, 0.05, 0.13, 0.05, 0.15, 0.05, 0.05]
    
    
    /* ************************************ */
    /* Data processing utilities            */
    
    /*
     * convert numbers (Integer, Double, etc) to Strings for percentage conversion
     */
    private func formatPercent(_ p: Double) -> String {
        percentageFormatter.string(from: NSNumber(value: p)) ?? "-"
    }
    
    /*
     * format numbers as percentages (as in "15%" instead of "0.15")
     */
    private var percentageFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        return f
    }()

    /*
     * format numbers as monetary values (as in "$1.99")
     */
    private var currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        // allow no currency symbol, extra digits, etc
        f.isLenient = true
        f.numberStyle = .currency
        return f
    }()
    
    
    /* ************************************ */
    /* Field processing utilities           */
    
    /*
     * calculate and format the Tip
     * @return Double
     */
    private var tipAmount: Double {
        let total = totalInput ?? 0
        let tipPercent = tipPercentages[selectedTipPercentage]
        return total * tipPercent
    }

    /*
     * @return Double
     */
    private var formattedTipAmount: String {
        currencyFormatter.string(from: NSNumber(value: tipAmount)) ?? "--"
    }

    // calculate and format the Tax
    private var taxAmount: Double {
        let total = totalInput ?? 0
        let taxPercent = taxPercentages[selectedTaxPercentage]
        return total * taxPercent
    }
    
    private var formattedTaxAmount: String {
        currencyFormatter.string(from: NSNumber(value: taxAmount)) ?? "--"
    }
    
    // calculate and format the Total
    private var finalTotal: Double {
        (totalInput ?? 0) + tipAmount + taxAmount
    }
    
    private var formattedFinalTotal: String {
        currencyFormatter.string(from: NSNumber(value: finalTotal)) ?? "--"
    }
    

    /* ************************************ */
    /* GUI building utilities               */

    /*
     * create a Horizontally separated Text label (on the left) and Text field (on the right)
     */
    private func summaryLine(a11yID: String, label: String, amount: String, color: Color) -> some View {
        HStack {
            Spacer()
            Text(label)
                .font(.title)
                .foregroundColor(color)
            Text(amount)
                .font(.title)
                .foregroundColor(color)
            }.padding(.trailing)
            .accessibility(identifier: a11yID)
    }
    
    /*
     * render tip selection "Picker" (dropdown, but with an iOS "segmented" styling)
     */
    private var segmentedTipPercentages: some View {
        Picker(selection: $selectedTipPercentage, label: Text("")) {
            ForEach(0..<tipPercentages.count) { index in
              Text(self.formatPercent(self.tipPercentages[index])).tag(index)
            }
        }.pickerStyle(SegmentedPickerStyle())
        .accessibility(identifier: "tipPercent")
    }

    /*
     * render tax selection "Picker" (dropdown, but with an iOS "wheel" styling)
     */
    private var spinnerTaxPercentages: some View {
        Picker(selection: $selectedTaxPercentage, label: Text("")) {
            ForEach(0..<self.provinces.count) { index in
                Text(self.provinces[index] + " - " + self.formatPercent(self.taxPercentages[index])).tag(index)
            }
        }.pickerStyle(WheelPickerStyle())
    }
    

    /* ************************************ */
    /* SwiftUI - "Design as Code"           */
    
    /*
     * build the GUI using SwiftUI
     */
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Spacer()

                TextField("Bill Amount", value: $totalInput, formatter: currencyFormatter)
                    .font(.largeTitle)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: "billAmountEditText")
                
                Text("Tip percent")
                segmentedTipPercentages
                    .padding()
                    .accessibility(identifier: "provincialTaxRate")
                
                HStack() {
                    Text("Tax: ")
                        .padding()
                    spinnerTaxPercentages
                        .padding()
                        .lineLimit(1)
                }
                Divider()
                
                summaryLine(a11yID: "tipAmount", label: "Tip:", amount: formattedTipAmount, color: .gray)
                summaryLine(a11yID: "taxAmount", label: "Tax:", amount: formattedTaxAmount, color: .gray)
                summaryLine(a11yID: "totalTextView", label: "Total:", amount: formattedFinalTotal, color: .green)
                
                Spacer()
            }
            .background(Color(white: 0.85, opacity: 1.0))
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle(Text("Tip Calculator"))
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
