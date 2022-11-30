//
//  ContentView.swift
//  BetterRest
//
//  Created by Edwin Przeźwiecki Jr. on 28/11/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                /// Challenge 1:
                Section {
                    DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                }
                
                /// Challenge 1:
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep:")
                }
                
                /// Challenge 1:
                Section {
                    /// Challenge 2:
                    Picker("Number of cups:", selection: $coffeeAmount) {
                        ForEach(0 ..< 21) {
                            Text("\($0)")
                        }
                    }
                } header: {
                    Text("Daily coffee intake:")
                }
                
                /// Challenge 3:
                Section {
                    Text("\(calculateBedtime())")
                        .font(.largeTitle)
                } header: {
                    Text("Your recommended bedtime:")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    /// Challenge 3:
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
