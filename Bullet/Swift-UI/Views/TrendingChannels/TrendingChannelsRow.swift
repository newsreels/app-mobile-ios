//
//  TrendingChannelsRow.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/6/22.
//

import SwiftUI

struct TrendingChannelsRow: View {
    
    @State var channelData: ChannelInfo
    var didFollow: (ChannelInfo) -> ()

    var body: some View {
        HStack {
            AppURLImage(channelData.image)
                .frame(width: 30, height: 30)
                .cornerRadius(10)
            AppText(channelData.name ?? "No channel name", weight: .semiBold, size: 15)
            Spacer()
            
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 25, height: 25)
                .overlay(checkmark)
                .onTapGesture {
                    didFollow(channelData)
                }
        }
        .background(Color.white)
        .onTapGesture {
            SwiftUIManager.shared.setObserver(name: .SwiftUIGoToChannelData, object: (channelData, self))
        }
       
        .padding(.vertical, 10)
    }
    
    private var checkmark: some View {
        VStack {
            if channelData.favorite ?? false {
                Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.AppPinkPrimary)
            } else {
                Image(systemName: "plus").font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

extension TrendingChannelsRow: ChannelDetailsVCDelegate {
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
        if let channel, channel.id == self.channelData.id {
            self.channelData = channel
        }
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
        if let channel, channel.id == self.channelData.id {
            self.channelData = channel
        }
    }
}
