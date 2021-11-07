//
//  MusicManager.swift
//  iRetro
//
//  Created by Max Nabokow on 2/19/21.
//

import Combine
import Foundation
import MediaPlayer

extension MPVolumeView {
	static func setVolume(_ volume: Float) {
		let volumeView = MPVolumeView()
		let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
			slider?.value = volume
		}
	}
}

class MusicManager {
    static let shared = MusicManager()
    private let player: MPMusicPlayerController
    
    private init() {
        player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
    }
    
    var playState: MPMusicPlaybackState {
        player.playbackState
    }
    
    var nowPlayingItem: MPMediaItem? {
        player.nowPlayingItem
    }
	
	func setVolume(_ value: Float){
		MPVolumeView.setVolume(value)
	}
    
    func play() {
        player.play()
    }
    
    func playPause() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func next() {
        player.skipToNextItem()
    }
    
    func previous() {
        if player.currentPlaybackTime <= 5 {
            player.skipToPreviousItem()
        } else {
            player.skipToBeginning()
        }
    }
    
    func stop() {
        player.stop()
        player.skipToBeginning()
    }

    func currentTimeInSong() -> TimeInterval {
        return player.currentPlaybackTime
    }

    func totalTimeInSong() -> TimeInterval {
        return player.nowPlayingItem?.playbackDuration ?? 0.0
    }
    
    func getPlaylists() -> [MPMediaPlaylist] {
        let playlists = MPMediaQuery.playlists()
        let collections = playlists.collections as? [MPMediaPlaylist]
        return collections ?? [MPMediaPlaylist]()
    }
    
    func getAllSongs() -> [MPMediaItem] {
        let songs = MPMediaQuery.songs().items
        return songs ?? [MPMediaItem]()
    }
    
    func getArtists() -> [MPMediaItemCollection] {
        let artists = MPMediaQuery.artists().collections
        return artists ?? [MPMediaItemCollection]()
    }
    
    func getAlbums() -> [MPMediaItemCollection] {
        let albums = MPMediaQuery.albums().collections
        return albums ?? [MPMediaItemCollection]()
    }
    
    func getCompilations() -> [MPMediaItemCollection] {
        let complications = MPMediaQuery.compilations().collections
        return complications ?? [MPMediaItemCollection]()
    }
    
    func getGenres() -> [MPMediaItemCollection] {
        let genres = MPMediaQuery.genres().collections
        return genres ?? [MPMediaItemCollection]()
    }
    
    func getComposers() -> [MPMediaItemCollection] {
        let composers = MPMediaQuery.composers().collections
        return composers ?? [MPMediaItemCollection]()
    }
    
    func getAudiobooks() -> [MPMediaItem] {
        let books = MPMediaQuery.audiobooks().items
        return books ?? [MPMediaItem]()
    }
    
    func playSong(id: String) {
        player.setQueue(with: [id])
        player.play()
    }
    
  
    func playShuffledSongs() {
        let shuffled = getAllSongs().shuffled()
        let collection = MPMediaItemCollection(items: shuffled)
        DispatchQueue.global(qos: .background).async {
            self.setQueue(with: collection)
            self.player.prepareToPlay()
            self.player.play()
        }
    }
    
    func playFavoriteSong() {
        let songs = getAllSongs()
        var songsPlayCount = [Int]()
        var favSongID = ""
        for song in songs {
            songsPlayCount.append(song.playCount)
            if songsPlayCount.max() == song.playCount {
                favSongID = song.playbackStoreID
            }
        }
        
        player.setQueue(with: [favSongID])
        player.play()
    }
    
    func setQueue(with collection: MPMediaItemCollection) {
        player.setQueue(with: collection)
    }
    
    func playArtistsSongs(artist: MPMediaItem) {
        let songs = getAllSongs()
        let filtered = songs.filter { $0.artist == artist.artist }
        
        setQueue(with: MPMediaItemCollection(items: filtered))
        player.play()
    }

    func getArtistsSongsCount(artist: MPMediaItem) -> Int {
        let songs = getAllSongs()
        let filtered = songs.filter { $0.artist == artist.artist }
   
        return filtered.count
    }

    func playComposersSongs(artist: MPMediaItem) {
        let songs = getAllSongs()
        let filteredSongs = songs.filter { $0.composer == artist.composer }
        
        setQueue(with: MPMediaItemCollection(items: filteredSongs))
        player.play()
    }

    func playGenreSongs(genre: MPMediaItem) {
        let songs = getAllSongs()
        let filteredSongs = songs.filter { $0.genre == genre.genre }
        
        setQueue(with: MPMediaItemCollection(items: filteredSongs.removeDuplicates()))
        player.play()
    }

    func playAlbumSongs(artist: MPMediaItem) {
        let songs = getAllSongs()
        let filteredSongs = songs.filter { $0.albumTitle == artist.albumTitle }
        
        setQueue(with: MPMediaItemCollection(items: filteredSongs))
        player.play()
    }

    private var sinks = Set<AnyCancellable>()
    
    func playStateChanged() -> AnyPublisher<MPMusicPlaybackState, Never> {
        return NotificationCenter.default
            .publisher(for: .MPMusicPlayerControllerPlaybackStateDidChange)
            .map { _ in
                self.playState
            }
            .eraseToAnyPublisher()
    }
    
    func nowPlayingChanged() -> AnyPublisher<Void, Never> {
        return NotificationCenter.default
            .publisher(for: .MPMusicPlayerControllerNowPlayingItemDidChange)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func queueChanged() -> AnyPublisher<Void, Never> {
        return NotificationCenter.default
            .publisher(for: .MPMusicPlayerControllerQueueDidChange)
            .map { _ in }
            .eraseToAnyPublisher()
    }
   
    #warning("Doesn't work yet")
    func libraryChanged() -> AnyPublisher<Void, Never> {
        return NotificationCenter.default
            .publisher(for: .MPMediaLibraryDidChange)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func volumeChanged() -> AnyPublisher<Void, Never> {
        return NotificationCenter.default
            .publisher(for: .MPMusicPlayerControllerVolumeDidChange)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
