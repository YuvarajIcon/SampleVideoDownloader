//
//  VideosViewModel+Extension.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation

extension VideosViewModel {
     func generateVideos() -> [Video] {
        var videos: [Video] = []
        let firstVideo = Video(context: CoreDataManager.shared.context)
        firstVideo.id = UUID().uuidString
        firstVideo.title = "Video 1"
        firstVideo.downloadURL = "https://player.vimeo.com/progressive_redirect/playback/433925279/rendition/1080p/file.mp4?loc=external&signature=50856478a378907bc656554b1de94f38a7704cc9206c9bff46a83cfb36f35e63"
        
        let secondVideo = Video(context: CoreDataManager.shared.context)
        secondVideo.id = UUID().uuidString
        secondVideo.title = "Video 2"
        secondVideo.downloadURL = "https://player.vimeo.com/progressive_redirect/playback/433927495/rendition/360p/file.mp4?loc=external&signature=02578fff5efc682f5afde55867c62a496a6a654107831fded0b3b48c8bd8038c"
        
        let thirdVideo = Video(context: CoreDataManager.shared.context)
        thirdVideo.id = UUID().uuidString
        thirdVideo.title = "Video 3"
        thirdVideo.downloadURL = "https://player.vimeo.com/progressive_redirect/playback/433664412/rendition/720p/file.mp4?loc=external&signature=c181e93e63d3979c0b9124f6a9dd98ea48c28d7d2598bedbe33f94663d6b16b6"
        
        let fourthVideo = Video(context: CoreDataManager.shared.context)
        fourthVideo.id = UUID().uuidString
        fourthVideo.title = "Video 4"
        fourthVideo.downloadURL = "https://player.vimeo.com/progressive_redirect/playback/433937419/rendition/1080p/file.mp4?loc=external&signature=5e84d1bcbbd42caf7fab6e63e284b0383b2e4e02f5cd6d76f102670099a5ff94"
        
        videos.append(contentsOf: [
            firstVideo, secondVideo, thirdVideo, fourthVideo
        ])
        
        return videos
    }
}
