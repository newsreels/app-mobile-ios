//
//  WeatherView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    
//    @StateObject var locationManager = LocationManager()
    @State private var weather: Weather?
    var country: String
    @State var isError: Bool = false

    var body: some View {
        Group {
            if let weather = weather {
                VStack {
                    SectionTitleView(title: "Weather", onTapSeeAll: { })
                        .padding(.bottom, 30)
                    Image("weatherBG")
                        .resizable()
                        .scaledToFill().cornerRadius(15)
                        .clipped()
                        .frame(height: 193)
                        .overlay(
                            HStack {
                                VStack (alignment: .leading){
                                    AppText(weather.location.country, weight: .semiBold, size: 16)
                                    Spacer()
                                    AppText(weather.current.condition.description, size: 14)
                                        .opacity(0.7)
                                }
                                Spacer()
                                VStack (alignment: .trailing){
                                    Spacer()
                                    AppText("\(weather.current.tempC)°", weight: .semiBold, size: 40)
                                    Spacer()
                                    AppText("Humidity: \(weather.current.humidity)", size: 14)
                                    AppText("Visibility: \(weather.current.visKm)km", size: 14)

                                }
                            }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 22))
                    
                }
                
                .padding(.horizontal)
                .padding(.bottom)
                
            } else {
                Color.clear.frame(height: 1)
            }

        }
        .onAppear {
//            getWeatherDetails()
        }
         
    }
    
    private func getWeatherDetails() {
        let parameters = ["key" : "49540cb90e394b4fa5f61208220706",
                          "q" : country,
                          "aqi" : "no",
                          "days" : 1,
                          "alerts" : "yes"] as [String: Any]
        let weatherService = CustomService(customBaseURL: URL(string: "http://api.weatherapi.com/v1/current.json"), method: .get, task: .requestParameters(parameters), parametersEncoding: .url, showLogs: true)
        print("WEATHER SERVICE = \(weatherService)")
        URLSessionProvider.shared.request(Weather.self, service: weatherService) { result in
            switch result {
            case .failure(let error):
                print("ERROR || Failed to get weather details \(error.localizedDescription)")
            case .success(let response):
                weather = response
            }
        }
        
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(country: "Los Banos")
            .previewLayout(.sizeThatFits)
    }
}
