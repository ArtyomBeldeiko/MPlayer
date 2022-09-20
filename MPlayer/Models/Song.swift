//
//  Song.swift
//  MPlayer
//
//  Created by Artyom Beldeiko on 15.09.22.
//

import Foundation

class Song {
    let songName: String
    let artistName: String
    let albumCover: UIImage
    let media: String
    let duration: String
    
    init(songName: String, artistName: String, albumCover: UIImage, media: String, duration: String) {
        self.songName = songName
        self.artistName = artistName
        self.albumCover = albumCover
        self.media = media
        self.duration = duration
    }
}

class Songs {
    var songs = [Song]()
    
    func songAppend() -> [Song] {
        var songs = [Song]()
        songs.append(Song(songName: "Honey Trap", artistName: "Hozho", albumCover: UIImage(named: "hozhoAlbumCover")!, media: "HozhoHoneyTrap", duration: "08:25"))
        songs.append(Song(songName: "Purple Noise", artistName: "Boris Brejcha", albumCover: UIImage(named: "borisBrejchaAlbumCover")!, media: "BorisBrejchaPurpleNoise", duration: "09:00"))
        songs.append(Song(songName: "Mark", artistName: "Shahmen", albumCover: UIImage(named: "shahmenAlbumCover")!, media: "ShahmenMark", duration: "02:01"))
        return songs
    }
}
