//
//  UploadTask.swift
//  Bullet
//
//  Created by Faris Muhammed on 01/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
import AVFoundation

struct UploadTask: Codable {
    
    var startTime: CMTime?
    var endTime: CMTime?
    var assetURL: URL?
    var aspectRatioWidth: CGFloat?
    var aspectRatioHeight: CGFloat?
    var imageCropFrame: CGRect?
    var taskId: String?
    var localURL: URL?
    var isEditing: Bool?
    
    var task_status: TaskStatus?
    var userUploadStatus: UserUploadStatus?
    var uploadType: UserUploadType?
    
    var uploadProgress: Double?
    
    var articleID: String?
    var sourceID: String?
    var serverURL: String?
    
    
    let videoRatio: CGSize?
    let contentOffset: CGPoint?
    let zoomScale: CGFloat?
    
    var contentInsetLeft: CGFloat?
    var contentInsetRight: CGFloat?
    var contentInsetTop: CGFloat?
    var contentInsetBottom: CGFloat?
    
    var isVideoScaling: Bool?
    
}


enum TaskStatus: String,Codable {
    case waitingForCropping
    case cropping
    case croppingCompleted
    case uploading
    case uploadingFailed
}


enum UserUploadStatus: String,Codable {
    case creating_post
    case posted
    case drafted
    case cancelled
}

enum UserUploadType: String,Codable {
    
    case reel
    case video
    
}


extension CMTime: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case timescale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(CMTimeValue.self, forKey: .value)
        let timescale = try container.decode(CMTimeScale.self, forKey: .timescale)
        self.init(value: value, timescale: timescale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(timescale, forKey: .timescale)
    }
}
