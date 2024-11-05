//
//  NotificationsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/5/22.
//

import SwiftUI

struct NotificationsView: View {
    
    let times: [String] = ["30m", "1h", "3h", "6h", "12h", "24h"]
    @State private var selectedTime: String = ""
    
    @State private var isBreakingNews: Bool = false
    @State private var isPersonalizedRecommendations: Bool = false

    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    var body: some View {
        VStack {
            VStack {
                HStack{Spacer()}
                
                SettingsSectionView(title: "Push Notifications") {
                    VStack {
                        SettingsRowView(settings: .switchToggle(iconName: "breakingNews_ic", title: "Breaking News", value: $isBreakingNews.onChange({ _ in
                            performWSToUpdateNotificationConfig()
                        })))
                        
                        SettingsRowView(settings: .switchToggle(iconName: "recommendations_ic", title: "Personalized Recommendations", value: $isPersonalizedRecommendations.onChange({ _ in
                            performWSToUpdateNotificationConfig()
                        })), showDivider: false)

                    }
                }
                
                SettingsSectionView(title: "Push Notifications") {
                    VStack (alignment: .leading, spacing: 0){
                        AppText("Set An Interval In Which You want To Receive News Notifications.", weight: .robotoRegular, size: 12, color: .black.opacity(0.5))
                            .padding(.top, 16)
                        
                        fromView
                            .padding(.vertical, 16)
                        
                        timeView

                    }
                    
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .background(Color.AppBG)
            .onTapGesture {
                Utilities.endEditing()
            }
        }
        .onAppear {
            performWSToGetNotificationConfig()
        }
        .navigationBar(title: "Settings")
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var fromView: some View {
        VStack (alignment: .leading){
            HStack {
                AppText("From:", weight: .medium, size: 12)
                DatePicker("Select a time", selection: $startTime.onChange({ date in
                    performWSToUpdateNotificationConfig()
                }), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .accentColor(.AppPinkPrimary)
            }
            
            HStack {
                AppText("    Till:", weight: .medium, size: 12)
                DatePicker("Select a time", selection: $endTime.onChange({ date in
                    performWSToUpdateNotificationConfig()
                }), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .accentColor(.AppPinkPrimary)

            }
        }
    }
    
    var timeView: some View {

        VStack (alignment: .leading, spacing: 16){
            AppText("Every", weight: .robotoRegular, size: 12, color: .black.opacity(0.5))
                .padding(.top, 16)
            HStack (alignment: .center){
                ForEach(times, id: \.self) { time in
                    Spacer()
                    AppText(time, weight: .nunitoSemiBold, size: 14, color: selectedTime == time ? .AppPinkPrimary : .AppGrayscale4)
                        .onTapGesture {
                            selectedTime = time
                            performWSToUpdateNotificationConfig()
                        }
                    Spacer()
                }
            }
            .padding(.vertical, 6)
            .background(Rectangle()
                .fill(Color.AppSecondaryGray)
                .cornerRadius(15))
            .padding(.bottom, 16)

        }

    }
}

extension NotificationsView {
    func performWSToUpdateNotificationConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        Utilities.showLoader()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let params = ["breaking": isBreakingNews, "personalized":isPersonalizedRecommendations, "frequency":self.selectedTime,
                      "start_time" : dateFormatter.string(from: startTime),
                      "end_time" : dateFormatter.string(from: endTime)] as [String : Any]
        // start_time
        // end_time
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/push", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            Utilities.hideLoader()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(UpdateNotificationConfig.self, from: response)
                
                if let message = FULLResponse.message {
                    
                    if message.lowercased() == "success" {
                        
                        self.performWSToGetNotificationConfig()
                    }
                }
                else {
                    
//                    ANLoader.hide()
                }
                
            } catch let jsonerror {
                Utilities.hideLoader()
//                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/push", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            Utilities.hideLoader()
//            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetNotificationConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        ANLoader.showLoading(disableUI: false)
//        Utilities.showLoader()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/push", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            Utilities.hideLoader()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(NotificationConfigDC.self, from: response)
                if let NotificationConfig = FULLResponse.push {
                    
                    isBreakingNews = NotificationConfig.breaking ?? false
                    isPersonalizedRecommendations = NotificationConfig.personalized ?? false
                    
                    selectedTime = NotificationConfig.frequency ?? ""
                    
                    if let startTime = NotificationConfig.start_time {
                        let timeArray = startTime.components(separatedBy: ":")
                        if let hours = Int(timeArray.first ?? "0"), let minutes = Int(timeArray.last ?? "0"), let date = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) {
                            self.startTime = date
                        }
                    }
                    
                    if let endTime = NotificationConfig.end_time {
                        let timeArray = endTime.components(separatedBy: ":")
                        if let hours = Int(timeArray.first ?? "0"), let minutes = Int(timeArray.last ?? "0"), let date = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()){
                            self.endTime = date
                        }
                    }
                    print("NotificationConfig.frequency.STARTTIME = \(NotificationConfig.start_time)")
                    print("NotificationConfig.frequency.ENDTIME = \(NotificationConfig.end_time)")

                    
//                    self.setOnOffNotification(breaking: breaking, personalized: personalized)
//
//                    if NotificationConfig.frequency == "30m" {
//
//                        self.btn30m.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn30m.tintColor = UIColor.white
//                    }
//                    else if NotificationConfig.frequency == "1h" {
//
//                        self.btn1h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn1h.tintColor = UIColor.white
//                    }
//                    else if NotificationConfig.frequency == "3h" {
//
//                        self.btn3h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn3h.tintColor = UIColor.white
//                    }
//                    else if NotificationConfig.frequency == "6h" {
//
//                        self.btn6h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn6h.tintColor = UIColor.white
//                    }
//                    else if NotificationConfig.frequency == "12h" {
//
//                        self.btn12h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn12h.tintColor = UIColor.white
//                    }
//                    else if NotificationConfig.frequency == "24h" {
//
//                        self.btn24h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
//                        self.btn24h.tintColor = UIColor.white
//                    }
//                    self.frequency = NotificationConfig.frequency ?? "1h"
                }
                
            } catch let jsonerror {
                Utilities.hideLoader()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/push", error: jsonerror.localizedDescription, code: "")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                Utilities.hideLoader()
//                ANLoader.hide()
            }
            
        }) { (error) in
            Utilities.hideLoader()
//            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }

}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
