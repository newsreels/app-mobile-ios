//
//  SettingsMainview.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI


class PushManager: ObservableObject {
    
    static let shared = PushManager()
    
    @Published var destinationView: AnyView = AnyView(ProfileView())
    @Published var isActive: Bool = false
    
}

struct PushView: View {
    
    @StateObject var pushManager = PushManager.shared
    
    var body: some View {
        NavigationLink(destination: pushManager.destinationView, isActive: .constant(pushManager.isActive)) {
            
        }
    }
}


struct SettingsMainview: View {
    
    @StateObject var settings = PushManager.shared
    @State private var readerMode: Bool = SharedManager.shared.readerMode
    @State private var autoplayVideos: Bool =  SharedManager.shared.reelsAutoPlay
    @State private var primaryLanguage: String = "English"
    @State private var secondaryLanguage: String = "Hindi"
    @State private var goPush: Bool = false
    @State var destinationView: AnyView = AnyView(ProfileView())
    
    @StateObject private var languageHelper = LanguageHelper.languageShared
    @State private var isShowRegionSelection : Bool = false
    
    @State private var user : UserProfile?
    
    @State private var region: NewRegion? = nil
    @State private var showConfirmAccount: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack (alignment: .leading, spacing: 32){
                        topSection
                        contentSettings
                        accountSettings
                        termsAndPolicy
                        if !SharedManager.shared.isGuestUser {
                            SettingsSectionView(title: "Account") {
                                SettingsRowView(settings: .normal(title: "Delete account")) {
                                    showConfirmAccount = true
                                }
                            }
                            .padding(.horizontal)
                        }
                        AppText("App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")", weight: .nunitoMedium, size: 14, color: .black.opacity(0.7))
                            .padding(.horizontal, 41)
                            .offset(y: -20)
                        SocialNetworkView()
                    }
                    
                }
                .navigationTitle(NSLocalizedString("Settings", comment: ""))
                .navigationBarTitleDisplayMode(.large)
                NavigationLink(destination: settings.destinationView, isActive: .constant(settings.isActive)) {
                }
            }
            .overlay(PushView())
        }
        .onAppear{
            autoplayVideos =  SharedManager.shared.reelsAutoPlay
        }
        .actionSheet(isPresented: $showConfirmAccount) {
            ActionSheet(
                title: Text("Are you sure you want to delete your account?"),
                buttons: [
                    .default(Text("No")) {
                    },
                    .default(Text("Yes").foregroundColor(.AppRed)) {
                        let customService = CustomService(customBaseURL: URL(string: "https://account.bullets.app/"), path: "auth/user", method: .delete, task: .requestPlain, needsAuthentication: true, usesContainer: false, showLogs: true)
                        URLSessionProvider.shared.request(service: customService) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .failure(let error):
                                    print("ERROR || Failed to delete account \(error.localizedDescription)")
                                case .success(let response):
//                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                                    appDelegate.logout()
                                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logoutClick)
                                    
                                    if !(SharedManager.shared.isConnectedToNetwork()){
                                        
                                        SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
                                        return
                                    }
                                    
                                    Utilities.showLoader()
                                    
                                    let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
                                    let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
                                    let params = ["token": refreshToken]
                                    
                                    WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
                                        
                                        Utilities.hideLoader()
                                        
                                        do{
                                            let FULLResponse = try
                                            JSONDecoder().decode(userDC.self, from: response)
                                            
                                            if FULLResponse.message?.lowercased() == "success" {
                                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                                appDelegate.newLogout()
                                            }
                                            
                                            
                                        } catch let jsonerror {
                                            Utilities.hideLoader()
                                            SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                                            print("error parsing json objects",jsonerror)
                                        }
                                        
                                    }){ (error) in
                                        
                                        Utilities.hideLoader()
                                        print("error parsing json objects",error)
                                    }

                                }
                            }
                        }
                    }
                ]
            )
        }
    }
    
    func setProfileData() {
        
        //        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
        //
        //            let profile = user.profile_image ?? ""
        //
        //            if profile.isEmpty {
        //
        //                //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
        //                imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
        //            }
        //            else {
        //                imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
        //            }
        //
        //            let fname = user.first_name ?? ""
        ////            let lname = user.last_name ?? ""
        //
        //            if fname.isEmpty {
        //
        //                profileRightArrow.isHidden = false
        //                lblEmail.text = NSLocalizedString("Create your profile", comment: "")
        //                lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
        //            }
        //            else {
        //                profileRightArrow.isHidden = false
        //                lblEmail.text = fname.capitalized //+ " " + lname
        //                lblViewProfile.text = NSLocalizedString("View your profile", comment: "")
        //            }
        //        }
        //        else {
        //
        //            //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
        //            imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
        //            lblEmail.text = NSLocalizedString("Create your profile", comment: "")
        //            lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
        //        }
        
    }
    
    
    var topSection: some View {
        SettingsSectionView {
            VStack {
                HStack (spacing: 16){
                    
                    if let user = user {
                        AppURLImage(user.profile_image ?? "")
                            .frame(width: 56, height: 56)
                            .cornerRadius(28)
                        
                        VStack (alignment: .leading, spacing:4){
                            Spacer()
                            AppText("\(user.first_name ?? "") \(user.last_name ?? "")", weight: .robotoSemiBold, size: 16)
                            if let username = user.username, !username.isEmpty {
                                AppText("@\(username)", weight: .nunitoLight, size: 10)
                                    .padding(.bottom, 16)
                            }
                            Spacer()
                        }
                        
                        Spacer()
                            .offset(y: 8)
                            .padding(.bottom, 8)
                        
                    } else {
                        Image("user_placeholder_ic")
                            .resizable()
                            .frame(width: 56, height: 56)
                        VStack (alignment: .leading, spacing:4){
                            AppText("Guest User", weight: .robotoSemiBold, size: 16)
                        }
                        .offset(y: 8)
                        .padding(.bottom, 8)
                        
                        Spacer()
                        
                    }
                    
                    
                }
                .background(Color.white)
                
                Rectangle()
                    .fill(Color.AppSecondaryGray)
                    .frame(height: 0.5)
                //                    .padding(.trailing, -24)
                    .padding(.leading, 70)
                
                
                if user?.isGuest == false {
                        SettingsRowView(settings: .normal(title: NSLocalizedString("View and Edit Your Profile", comment: "")), showDivider: false) {
                            settings.isActive = true
                            settings.destinationView = AnyView(ProfileView())
                        }
                    } else {
                        SettingsRowView(settings: .normal(title: NSLocalizedString("Create A new Account", comment: "")), showDivider: false) {
                            NotificationCenter.default.post(name: .SwiftUIGoToRegister, object: nil)
                        }
                    }
                
            }
            .background(Color.white)
            
            .padding(.top, 12)
        }
        .padding(.horizontal)
        .padding(.top, 32)
        .onAppear {
            if let profileUser = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                user = profileUser
            }
            languageHelper.getAllRegions()
        }
        .actionSheet(isPresented: $isShowRegionSelection) {
            ActionSheet(title: Text(NSLocalizedString("Select Your Region", comment: "")), message: Text(NSLocalizedString("Changing Language Description", comment: "")), buttons: actionSheetButtons)
        }
    }
    
    var contentSettings: some View {
        SettingsSectionView(title: NSLocalizedString("Content Settings", comment: "")) {
            VStack (spacing: 0) {
                SettingsRowView(settings: .selection(iconName: "language_ic", title: NSLocalizedString("Primary Language", comment: ""), description: primaryLanguage)) {
                    if let region = LanguageHelper.shared.getSavedRegion() {
                        languageHelper.getLanguage(withRegionID: region.id) {
                            settings.isActive = true
                            settings.destinationView = AnyView(LanguageSelectorView(languages: languageHelper.languages, navTitle: NSLocalizedString("Primary Language", comment: ""), selectedLanguage: LanguageHelper.shared.getSavedLanguage() ?? languageHelper.selectedLanguage, dismiss: { language in
                                ANLoader.showLoading()
                                LanguageHelper.shared.saveLanguage(language: language, isInSettings: true)
                                languageHelper.selectedLanguage = language
                                languageHelper.saveSelectedRegionAndLanguage(isInSettings: true, completion: {
                                    DispatchQueue.main.async {
                                        SwiftUIManager.shared.setObserver(name: .SwiftUIDidChangeLanguage, object: true)
                                    }
                                })
                                primaryLanguage = language.name
                                settings.isActive = false
                            }))
                        }
                    } else {
                        isShowRegionSelection = true
                    }
                }
                
                
                SettingsRowView(settings: .selection(iconName: "language_ic", title: NSLocalizedString("Secondary Language", comment: ""), description: secondaryLanguage)) {
                    if let region = LanguageHelper.shared.getSavedRegion() {
                        languageHelper.getLanguage(withRegionID: region.id) {
                            settings.isActive = true
                            settings.destinationView = AnyView(LanguageSelectorView(languages: languageHelper.languages, navTitle: NSLocalizedString("Secondary Language", comment: ""), selectedLanguage: LanguageHelper.shared.getSecondaryLanguage() ?? languageHelper.selectedLanguage, dismiss: { language in
                                LanguageHelper.shared.saveSecondaryLanguage(language: language, isInSettings: true)
                                secondaryLanguage = language.name
                                settings.isActive = false
                            }))
                        }
                    } else {
                        isShowRegionSelection = true
                    }
                }
                
                SettingsRowView(settings: .normal(iconName: "notif_ic", title: NSLocalizedString("Notification Settings", comment: ""))) {
                     settings.isActive = true
                    settings.destinationView = AnyView(NotificationsView())
                    
                }
                SettingsRowView(settings: .normal(iconName: "fontsize_ic", title: NSLocalizedString("Font Size", comment: ""))) {
                     SwiftUIManager.shared.setObserver(name: .SwfitUIGoToFontSize, object: nil)
                    
                }
                SettingsRowView(settings: .selection(iconName: "region_ic", title: NSLocalizedString("Region", comment: ""), description: languageHelper.selectedRegion?.name ?? "")) {
                    isShowRegionSelection = true
                    //                    settings.isActive = true
                    //                    settings.destinationView = AnyView(LanguageOnboardingView(dismiss: {
                    //                        primaryLanguage = LanguageHelper.shared.getSavedLanguage()?.name ?? ""
                    //                        settings.isActive = false
                    //                    }, isInSettings: true).navigationBarHidden(true))
                }
                
//                SettingsRowView(settings: .switchToggle(title: NSLocalizedString("Auto Play Video And Reels", comment: ""), value: $autoplayVideos.onChange({ value in
//                    UserDefaults.standard.set(value, forKey: Constant.UD_isReelsAutoPlay)
//                    SharedManager.shared.bulletsAutoPlay = value
//                    self.performWSToUpdateConfigView()
//
//                })))
                
                //                SettingsRowView(settings: .switchToggle(title: NSLocalizedString("Reader Mode", comment: ""), value: $readerMode.onChange({ value in
                //                    UserDefaults.standard.set(value, forKey: Constant.UD_isReaderMode)
                //                    SharedManager.shared.readerMode = value
                //                    self.performWSToUpdateConfigView()
                //
                //                })), showDivider: false)
                
            }
            
        }
        .padding(.horizontal)
        
        .onLoad {
            primaryLanguage = LanguageHelper.shared.getSavedLanguage()?.name ?? ""
            secondaryLanguage = LanguageHelper.shared.getSecondaryLanguage()?.name ?? ""
            autoplayVideos = SharedManager.shared.bulletsAutoPlay
        }
    }
    
    var accountSettings: some View {
        SettingsSectionView(title: NSLocalizedString("Account Settings", comment: "")) {
            VStack (spacing: 0) {
                
                
                SettingsRowView(settings: .normal(iconName: "saved_ic", title: "Saved")) {
                    print("Saved")
                    SwiftUIManager.shared.setObserver(name: .SwfitUIGoToFavArticles, object: nil)
                }
                
                SettingsRowView(settings: .normal(iconName: "emailPW_ic", title: NSLocalizedString("Change Password", comment: ""))) {
                    print("Email and Password")
                    SwiftUIManager.shared.setObserver(name: .SwiftUIGoToChangePassword, object: nil)
                    
                }
                
                SettingsRowView(settings: .normal(iconName: "blocklist_ic", title: NSLocalizedString("Block List", comment: ""))) {
                    print("Block List")
                    SwiftUIManager.shared.setObserver(name: .SwiftUIGoToBlockList, object: nil)
                    
                }
                if user?.isGuest == false {
                    SettingsRowView(settings: .normal(iconName: "logout_ic", title: NSLocalizedString("Logout", comment: "")), showDivider: false) {
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logoutClick)
                        
                        
                        if !(SharedManager.shared.isConnectedToNetwork()){
                            
                            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
                            return
                        }
                        
                        Utilities.showLoader()
                        
                        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
                        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
                        let params = ["token": refreshToken]
                        
                        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
                            
                            Utilities.hideLoader()
                            
                            do{
                                let FULLResponse = try
                                JSONDecoder().decode(userDC.self, from: response)
                                
                                if FULLResponse.message?.lowercased() == "success" {
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    self.user = nil
                                    
                                    let emptyUser = UserProfile()
                                    let encoder = JSONEncoder()
                                    if let encoded = try? encoder.encode(emptyUser) {
                                        SharedManager.shared.userDetails = encoded
                                    }
                                    
                                    appDelegate.newLogout()
                                }
                                
                                
                            } catch let jsonerror {
                                Utilities.hideLoader()
                                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                                print("error parsing json objects",jsonerror)
                            }
                            
                        }){ (error) in
                            
                            Utilities.hideLoader()
                            print("error parsing json objects",error)
                        }
                    }
                } else   {
                    SettingsRowView(settings: .normal(iconName: "login_ic", title: NSLocalizedString("Login", comment: "")), showDivider: false) {
                        NotificationCenter.default.post(name: .SwiftUIGoToRegister, object: nil)
                    }
                }
            }
            
        }
        .padding(.horizontal)
    }
    
    var termsAndPolicy: some View {
        SettingsSectionView(title: NSLocalizedString("Terms Policy", comment: "")) {
            VStack (spacing: 0) {
                
                SettingsRowView(settings: .normal(iconName: "terms_ic", title: NSLocalizedString("Terms & Conditions", comment: "Terms & Conditions"))) {
                    settings.isActive = true
                    settings.destinationView = AnyView(ContentNoteView(textContent: """
                    Welcome to Newsreels, your go-to no-nonsense news aggregator app tailored especially for you, by you.
                    
                    We are dedicated to delivering the freshest news that you want in easily digestible bullets for quick reading on-the-go. However, our lawyers insist on including this legal fine print, so we made everything as quickly understandable as the news beats you came here for.
                    
                    These Terms of Use (“Terms”) apply to your use of the (i) Newsreels website located at newsreels.app; (ii) all associated sites linked to newsreels.app (collectively, the “Site”); and (iii) the application (the “App”) connected herewith. Both the Site and the App are owned and operated by Newsreels LLC (“Newsreels”) and its licensors. Using the Site and the App constitutes an agreement to the following Terms. Should you disagree with or have any questions regarding any or all of the points, please pause your use and get in touch with our team through our contact page.
                    
                    Newsreels reserves the right, at its sole discretion, to change, modify, add, or remove portions of these Terms at any time without notice. While we maintain responsibility for the quality of the Site and the App, you share an equal duty to constantly check for updates that may appear herein. Your continued use of the Services following any update will mean an agreement to any changes. As long as you comply with these Terms of Use, Newsreels grants you a personal, non-exclusive, non-transferable, limited privilege to enter and use the Site.
                    
                    Content
                    The content and elements you see in both the Site and App may be covered by relevant intellectual property laws. You will find quite a number of materials in our Services; so, in true Newsreels fashion, here is a quick rundown of said materials, in bullets, of course:
                    
                    Newsreels’ Service, Products, and Brand
                    Our products and services, as well as the presentation of such within the Site and the App, are protected by intellectual property laws. Newsreels grants you a personal, worldwide, non-assignable, license to use these, provided that your use remains in accordance with relevant trademark, copyright, patent, or other similar laws.
                    Service Use Guidelines
                    You promise to maintain the integrity of the Site and the App by using the service solely for lawful purposes. You may not lift any material without including attached proprietary notice language or copyright expressions. Furthermore, you are expressly prohibited from using any elements found or produced herein for commercial, non-personal use.
                    Republishing Content
                    As we work hard to maintain the veracity and the accuracy of the news beats delivered to you, we expect you to keep them as is should you decide to republish them on your personal social media pages or other social platforms. We are all for fast news, but never fake news.
                    User-Generated Content
                    All the news articles found in the App come from submissions from its users (or “Editors”). All Editors are asked to furnish a 500-character bullet-form summary of their news submissions. The sources for each article should always be tagged for each article.
                    Privacy
                    For clarity and security, we also provide you with a separate, more detailed Privacy Policy statement which explains in certain terms our collection and use of any information we may require from you. These policies are periodically updated to conform with advancements global practices regarding data protection and cybersecurity.
                    
                    Security
                    We make every effort to deliver the most accurately aggregated news for you. It also follows that our pursuit of effective and quick information comes with even stronger measures designed to protect your account and the personally identifiable information (PII) associated thereunder. However, despite our consistently advancing security protocols, there are still persistent threats around the internet. For this reason, we would appreciate your contribution to our security initiatives through vigilant reporting whenever you find any anomalous activities within your account.
                    
                    Copyright
                    Newsreels is a staunch believer of truth in reporting. We respond well to takedown notices should anyone decide to lodge concerns regarding any copyrighted content deemed by the copyright holder infringing on their legal rights.
                    
                    For copyrights-related concerns, please use our contact form provided on the homepage.
                    
                    Disclaimers
                    All Services provided herein are strictly given “as is” without any warranty, express or implied. Newsreels disclaims all warranties and conditions of merchantability, fitness for a particular use outside personal information, and non-infringement.
                    
                    Limitation of Liability
                    To the fullest extent allowed by law, Newsreels shall not be liable for any indirect, incidental, special, consequential or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill or other intangible losses resulting from (i) your access to, use of, inability to access or inability to use the Site and the App; (ii) any third party conduct or content on Newsreels, including any defamatory, offensive or illegal conduct of third parties; or (iii) any unauthorized access, use or alteration of the published content.
                    
                    Arbitration
                    If, for any reason, you are dissatisfied with Newsreels to the point of seeking legal recourse, we implore you to first work out our differences informally. We strongly encourage you to go through an initial conversation with our help desk to resolve any disputes in good faith. Like you, we are reasonable people who only want the best for everyone. If the issues persist after attempting to resolve them internally, we shall resolve any dispute you have with us on an individual basis in arbitration, and not as a class arbitration, class action, or consolidated proceeding of any kind.
                    
                    Governing Law and Jurisdiction
                    These Terms will be governed by the laws of the State of Delaware, except for its conflict of laws principles. For claims that aren’t subject to arbitration, we each agree that any such claims shall be litigated exclusively in a state court located in areas which we shall disclose upon request.
                    
                    Entire Agreement
                    These Terms and our Privacy Policy constitute the entire agreement between you and Newsreels. If any provision of these Terms is found to be unenforceable, the remaining provisions will continue to be in full force and effect.
                    
                    Modification
                    The points contained herein may be modified periodically to address changing conventions. To keep you up to date with changes in the Terms, all revisions will always be posted at the same URL in which you are reading this right now (newsreels.app/terms); and, previous versions shall be made available upon request. If there will be significant changes that we deem impactful on your rights, we shall post a notification within the Site or the App. Your continued use of Newsreels constitutes your agreement to accept any changes or revisions to these Terms.
                    
                    Contact
                    We welcome all questions, concerns, or feedback you may have regarding the Terms mentioned. If you have any suggestions, clarifications, or if you wish to comment on this statement, you are more than welcome to drop us a line through the contact form found on our homepage.
                    """, title: "Terms & Conditions"))
                    
                    print("Terms and conditions")
                }
                
                SettingsRowView(settings: .normal(iconName: "privacy_ic", title: NSLocalizedString("Privacy Policy", comment: ""))) {
                    settings.isActive = true
                    settings.destinationView = AnyView(ContentNoteView(textContent: """
                    Newsreels values your privacy and data security. While we work double-time to deliver your choice of news topics for just half the time other news service providers would take, we also put effort in the background to keep your choices and other privacy-related information secure.
                    
                    In true Newsreels fashion, we chopped the clutter of legal jargon and developed this policy in simple and easily understandable terms.
                    
                    In this Privacy Policy statement, we will take you through how we collect, use, disclose, transfer, and store your personal information. Please read this confidentiality statement carefully as the points mentioned hereunder apply to all interactions you have with our products and services. This privacy policy covers you, our audience, and does not apply to the information Newsreels collects from its employees and contractors.
                    
                    By accessing or using this website, the products, and services from which this privacy policy is referenced, you confirm that you have read, understood, and acknowledge the terms herein. Another important note is that this does not constitute a legally binding contract, and thus, it cannot be used as grounds for any legal obligations.
                    
                    We understand that many of us would rather tick a box, agree without reading first, or mostly just ignore privacy statements. So, we made the following policy as concise and light as possible. And in bullets, too.
                    
                    The Information We Collect
                    When you use this website or the Newsreels app, we may need to collect, receive, or develop the following categories of information from or about you:
                    
                    Identifiable information, contact details, and other account information. This includes your name, username, and password associated with your account.
                    Demographic information. We may collect information relating to your particular group like gender, reading preference, locality, and others.
                    Payment information. This information would be collected should you decide to subscribe to any of our paid services.
                    Information you provide. When you customise your topic preferences and choose specific sources for your news, we may collect these information to tailor your reading experience to your liking. These data may also play in the advertisements displayed in the app.
                    Location information. To help you connect with articles closer to home, we may use your location information to keep you updated on the news around you.
                    Inferences. Using any or all of the information mentioned above, our systems may draw inferences about you, reflecting what we believe would elevate your experience with our services.
                    How We Collect Your Information
                    We collect personal information about you from various sources. Here’s a quick rundown of the places from which we may gather information:
                    
                    Directly from you. We may request and collect information from you such as when you contact us through different channels available on both the website and the app. Your information would also be made available to us when you create or customise your profile, and when you decide to purchase any of our paid services.
                    Passively from your devices. Information about you may also come from various tracking technologies such as web beacons, cookies, and embedded scripts to automatically collect information about you when you interact with the website, app, ads, or emails.
                    From third parties. Should you opt to connect your account with a third party service, your information present from the said third party would be sent over to us. This happens when you sign in or create an account using your social media channels or email, or when you reshare content on your personal external accounts.
                    From affiliated vendors. For instance, we may engage with vendors and service providers to collect or provide us with information about you, such as access to location services via wireless networks or cell towers near your mobile device, or your IP address.
                    From the news outlets you enjoy. Additionally, we may obtain your data from the news websites and other sources you interact with while using our services.
                    And from our interpretation of the combination of any or all of the information gathered from the abovementioned sources.
                    How We Disclose to Third Parties
                    Under the following circumstances, we may disclose your personal information to third parties:
                    
                    We share information with our marketing partners. Newsreels may work with advertising partners to serve you third-party advertisements, including interest-based advertisements, on Newsreels and on other services. Personal information received by our marketing partners and other parties may also be subject to their privacy policies. To learn about how to control how we share your information with marketing partners, please review Your Choices in the succeeding sections.
                    If need be, we may disclose information as required by the law, for safety and security purposes.
                    Our vendors and service providers may receive information that would help us offer and improve our services.
                    We may share personal information if we sell, transfer or otherwise share some or all of our assets in connection with a merger, acquisition, reorganization or sale of assets in the event of a bankruptcy.
                    How We Protect Your Data
                    We work extra hard to protect your data, especially in the fast-paced environment of the internet. However, this very landscape is shifting and threats are getting more sophisticated and creative, albeit decidedly nefarious. So, we advise you to practice caution when using the internet. While you take measures to protect yourself, we are with you on protecting your cybersecurity from our end.
                    
                    Data Retention - in compliance with prevailing legal and regulatory conventions, we store your data in a secure digital environment. The length of time we retain your information depends solely on the purposes described in this policy.
                    Data Security - following the guardrails defined by the law, we employ strategies through our teams to prevent breaches which could potentially compromise your information.
                    Your Choices
                    Similar to the freedom you have to choose the kind of news that you love, you are also free to exercise discretion when dealing with your personal information and online data. For instance, you may:
                    
                    Opt out of receiving our marketing materials.
                    Control certain cookies and tracking tools. Cookies and HTML5 local storage are ways to keep information about your use of Internet services on your own mobile device or computer. These technologies help us better understand user behavior, tell us which parts of our websites people have visited, and facilitate and measure the effectiveness of advertisements and web searches.
                    
                    We treat information collected by cookies and other technologies as non‑personal information. However, to the extent that Internet Protocol (IP) addresses or similar identifiers are considered personal information by local law, we also treat these identifiers as personal information. Similarly, to the extent that non-personal information is combined with personal information, we treat the combined information as personal information for the purposes of this Privacy Policy.
                    Deletion of Data
                    You may decide to completely remove your data from our system by contacting us directly at contact@newsinbullets.app.
                    
                    After confirming your intent, we then begin the process to safely and completely delete your data from our storage. In order to make sure that there is no accidental data loss, this process may take up to 2 months to complete.
                    
                    As with any deletion process, things like routine maintenance, unexpected outages, bugs, or failures in our protocols may cause delays in the processes and timeframes defined in this article. We maintain systems designed to detect and remediate such issues.
                    
                    Modifications
                    The points contained herein may be modified periodically to address changing conventions. To keep you up to date with changes in the Privacy Policy, all revisions will always be posted at the same URL in which you are reading this right now (newsreels.app/privacy); and, previous versions shall be made available upon request. If there will be significant changes that we deem impactful on your rights, we shall post a notification within the Site or the App. Your continued use of Newsreels constitute your agreement to accept any changes or revisions to this Privacy Policy.
                    
                    Contact
                    We welcome all questions, concerns, or feedback you may have regarding our Privacy Policy. If you have any suggestions, clarifications, or if you wish to comment on this statement, you are more than welcome to drop us a line through the contact form found in our homepage.
                    """, title: "Privacy Policy"))
                }
                
                //                SettingsRowView(settings: .normal(iconName: "communityGuidelines_ic", title: "Community Guidelines")) {
                //                    settings.isActive = true
                //                    settings.destinationView = AnyView(ContentNoteView(textContent: """
                //                    Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.
                //
                //                    The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
                //                    The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
                //                    The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced
                //                    """, title: "Community Guidelines"))
                //                }
                
                SettingsRowView(settings: .normal(iconName: "about_ic", title: NSLocalizedString("About", comment: ""))) {
                    print("About")
                    settings.isActive = true
                    settings.destinationView = AnyView(AboutView())
                    
                }
                
                SettingsRowView(settings: .normal(iconName: "helpFeedback_ic", title: NSLocalizedString("Help and Feedback", comment: "")), showDivider: false) {
                    print("Help and Feedback")
                    settings.isActive = true
                    settings.destinationView = AnyView(HelpAndFeedBackView())
                    
                }
            }
            
        }
        .padding(.horizontal)
    }
    
    var actionSheetButtons: [ActionSheet.Button] {
        var array : [ActionSheet.Button] = []
        languageHelper.regions.map { region in
            array.append(.default(Text(region.name), action: {
                languageHelper.getLanguage(withRegionID: region.id) {
                    settings.isActive = true
                    settings.destinationView = AnyView(LanguageSelectorView(languages: languageHelper.languages, navTitle: "Primary Language", selectedLanguage: LanguageHelper.shared.getSavedLanguage() ?? languageHelper.selectedLanguage, dismiss: { language in
                        DispatchQueue.main.async {
                            languageHelper.selectedRegion = region
                            LanguageHelper.shared.saveRegion(region: region)
                            
                            LanguageHelper.shared.saveLanguage(language: language, isInSettings: true)
                            languageHelper.selectedLanguage = language
                            languageHelper.saveSelectedRegionAndLanguage(isInSettings: true, completion: {
                                DispatchQueue.main.async {
                                    SwiftUIManager.shared.setObserver(name: .SwiftUIDidChangeLanguage, object: true)
                                }
                            })
                            primaryLanguage = language.name
                            settings.isActive = false
                        }
                        
                    }))
                    
                }
            }))
        }
        array.append(.destructive(Text("Cancel")){})
        return array
    }
    
    func performWSToUpdateConfigView() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        //        ANLoader.showLoading(disableUI: true)
        let params = [
            "reader_mode": SharedManager.shared.readerMode,
            "bullets_autoplay": SharedManager.shared.bulletsAutoPlay,
            "reels_autoplay": SharedManager.shared.reelsAutoPlay,
            "videos_autoplay": SharedManager.shared.videoAutoPlay
        ]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                if let _ = FULLResponse.message {
                    
                    print("Success")
                    
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "user/config/view", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
    }
}

struct SettingsMainview_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainview()
    }
}

