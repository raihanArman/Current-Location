//
//  ContentView.swift
//  Current Location
//
//  Created by Raihan Arman on 20/07/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    var body: some View {
        VStack {
            if let weatherData = weatherData {
                Text("\(Int(weatherData.temperature)) celcius")
                    .font(.custom("", size: 70))
                    .padding()
                
                VStack {
                    Text("\(weatherData.locationName)")
                        .font(.title2).bold()
                    Text("\(weatherData.condition)")
                        .font(.body).bold()
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("Chek check")
                    .bold()
                    .padding()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 300, height: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .onAppear {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$location) { location in
            guard let location = location else { return }
            fetchWeatherData(for: location)
        }
    }
    
    private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "24177ac29ebc0f71ef7d68e8b12f6563"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    weatherData = WeatherData(locationName: weatherResponse.name, temperature: weatherResponse.main.temp, condition: weatherResponse.weather.first?.description ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
