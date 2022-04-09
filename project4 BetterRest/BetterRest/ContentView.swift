import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = true
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        
        NavigationView {
            Form {
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                
                }
                Section(header: Text("Your recommended bed time is...").foregroundColor(Color(UIColor.black))) {
                    Text(calculateBedTime())
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .frame(width: 200, height: 100, alignment: .center)
                        .foregroundColor(Color(UIColor.systemBlue))
                }
            }.navigationTitle("BetterRest")
        }
    }
    func calculateBedTime() -> String {
        do{
        let config = MLModelConfiguration()
        let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                let sleepTime = wakeUp - prediction.actualSleep

                let formatter = DateFormatter()
                formatter.timeStyle = .short

                return formatter.string(from: sleepTime)
            } catch {
                return "Sorry, there was a problem calculating your bedtime."
            }
      }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
}
