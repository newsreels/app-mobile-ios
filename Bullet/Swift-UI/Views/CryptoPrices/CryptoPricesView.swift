//
//  CryptoPricesView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct CryptoPricesView: View {
    
    @State private var crypto : [[Crypto]]?
    @State var isError: Bool = false

    var body: some View {
        
        if let crypto = crypto {
            VStack (spacing: 0){
                SectionTitleView(title: NSLocalizedString("Crypto Prices", comment: "")) { }
                    .padding(.horizontal)
                ScrollView (.horizontal, showsIndicators: false){
                    HStack (alignment: .top, spacing: 8){
                        
                        ForEach(0..<(crypto.count - 1)) { value in
                            VStack (alignment: .leading){
                                
                                ForEach(crypto[value], id: \.name) { coin in
                                    
                                    let icon : CardIcon = !coin.iconUrl.contains("svg") ? .init(icon: .url(coin.iconUrl)) : .init(icon: .local(Image(systemName: "bitcoinsign.circle")), backgroundColor: .CardOrange)
                                    
                                    CardView(cardIcon: icon) {
                                        VStack (alignment: .leading, spacing: 8){
                                            HStack (spacing: 2){
                                                AppText(coin.symbol, weight: .medium, size: 14, lineSpacing: 0)
                                                    .lineLimit(2)
                                                Spacer()
                                                if coin.change.prefix(1) == "-" {
                                                    Image("upRed")
                                                        .rotationEffect(.degrees(-180))
                                                    AppText("\(coin.change) %", weight: .medium, size: 10, color: Color.AppLightRed)
                                                } else {
                                                    Image("upGreen")
                                                    AppText("\(coin.change) %", weight: .medium, size: 10, color: Color.AppColorGreen)
                                                }
                                            }
                                            let doublePrice = Double(coin.price)
                                            AppText("$\(String(format: "%.2f", doublePrice ?? 0))", size: 12, color: .black.opacity(0.4))
                                        }
                                        .padding(.trailing, -12)
                                        
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 40)
                    .padding(.horizontal)
                }
                .padding(.vertical, -24)
            }
        } else {
            if !isError {
                loadingView
                    .onAppear {
                        let customService = CustomService(customBaseURL: URL(string: "https://api.coinranking.com/v2"), path: "coins", method: .get, task: .requestPlain, usesContainer: true,showLogs: true, customHeaders: ["x-access-token" : "coinranking8f95c45a6e7bd7d95b1bc46c8008d86e82298bd38024ce90"])
                        URLSessionProvider.shared.request(CryptoResponse.self, service: customService) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .failure(let error):
                                    print("ERROR || Failed to get crypto response \(error.localizedDescription)")
                                case .success(let response):
                                    let coins = response.coins
                                    self.crypto = coins.unflattening(dim: 2)
                                }
                            }
                        }
                    }

            }
        }
        
    }
    
    var loadingView: some View {
        VStack {
            VStack (alignment: .leading, spacing: 24){
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 35)
                    .cornerRadius(10)
                
                ScrollView (.horizontal) {
                    HStack (spacing: 8){
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 20)
                .disabled(true)
            }
        }
        .padding(.bottom)
        .padding(.leading)
        
    }
    
}

struct CryptoPricesView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoPricesView()
    }
}
