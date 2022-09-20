//
//  ViewController.swift
//  MPlayer
//
//  Created by Artyom Beldeiko on 11.09.22.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, iCarouselDelegate, iCarouselDataSource, AVAudioPlayerDelegate {
    
//    MARK: Constants and variables
    
    let carousel = iCarousel(frame: CGRect(x: 0, y: 0, width: 309, height: 309))
    var songs = Songs().songAppend()
    var currentSong = 0
    var isPlayed = false
    var player = AVAudioPlayer()
    
//    MARK: UI Elements Setup
    
    let blurView: UIImageView = {
        let blurImageView = UIImageView()
        blurImageView.image = UIImage(named: "Blur")
        blurImageView.translatesAutoresizingMaskIntoConstraints = false
        blurImageView.layer.masksToBounds = true
        return blurImageView
    }()
    
    let songNameLabel: UILabel = {
        let songName = UILabel()
        songName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        songName.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        songName.font = songName.font.withSize(20)
        songName.translatesAutoresizingMaskIntoConstraints = false
        return songName
    }()
    
    let artistNameLabel: UILabel = {
        let artistName = UILabel()
        artistName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        artistName.font = UIFont(name: "Montserrat-Regular", size: 14)
        artistName.font = artistName.font.withSize(14)
        artistName.translatesAutoresizingMaskIntoConstraints = false
        return artistName
    }()
    
    lazy var durationSlider: CustomSlider = {
        let slider = CustomSlider()
        slider.minimumTrackTintColor = UIColor(red: 0.51, green: 0.341, blue: 0.906, alpha: 1)
        slider.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.addTarget(self, action: #selector(scrubMedia), for: .touchUpInside)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        return slider
    }()
    
    let leadingDurationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        durationLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
        durationLabel.font = durationLabel.font.withSize(12)
        durationLabel.text = "00:00"
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        return durationLabel
    }()
    
    let trailingDurationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        durationLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
        durationLabel.font = durationLabel.font.withSize(12)
        durationLabel.text = "00:00"
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        return durationLabel
    }()
    
    lazy var previousButton: UIButton = {
        let previousButton = UIButton()
        previousButton.setImage(UIImage(named: "previousButton"), for: .normal)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.layer.masksToBounds = true
        previousButton.addTarget(self, action: #selector(previousSong), for: .touchUpInside)
        return previousButton
    }()
    
    lazy var playButton: UIButton = {
        let playButton = UIButton()
        playButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.02)
        playButton.setImage(UIImage(systemName: "play.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 45)), for: .normal)
        playButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        playButton.clipsToBounds = true
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playSong), for: .touchUpInside)
        return playButton
    }()
    
    lazy var pauseButton: UIButton = {
        let pauseButton = UIButton()
        pauseButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.02)
        pauseButton.setImage(UIImage(systemName: "pause.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 45)), for: .normal)
        pauseButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        pauseButton.clipsToBounds = true
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(pauseSong), for: .touchUpInside)
        return pauseButton
    }()
    
    lazy var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setImage(UIImage(named: "nextButton"), for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.layer.masksToBounds = true
        nextButton.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
        return nextButton
    }()

//    MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carousel.dataSource = self
        carousel.type = .coverFlow
        carousel.isScrollEnabled = false
        carousel.translatesAutoresizingMaskIntoConstraints = false
        currentSong = carousel.currentItemIndex
        
        player.delegate = self
        
        view.backgroundColor = UIColor(red: 0.114, green: 0.09, blue: 0.149, alpha: 1)
        view.addSubview(blurView)
        view.addSubview(songNameLabel)
        view.addSubview(artistNameLabel)
        view.addSubview(durationSlider)
        view.addSubview(leadingDurationLabel)
        view.addSubview(trailingDurationLabel)
        view.addSubview(previousButton)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(nextButton)
        view.addSubview(carousel)
        
        configureConstraints()
        
        pauseButton.isHidden = true
        
        songNameLabel.text = songs[0].songName
        artistNameLabel.text = songs[0].artistName
    }
    
//    MARK: viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        pauseButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
    }
    
//    MARK: Carousel Methods
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return songs.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageView: UIImageView
        
        if view != nil {
            imageView = view as! UIImageView
        } else {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 309, height: 309))
        }
        
        imageView.image = songs[index].albumCover
       
        return imageView
    }
    
//    MARK: Constraints Setup
    
    private func configureConstraints() {
        
        let blurViewConstraints = [
            blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3),
            blurView.heightAnchor.constraint(equalToConstant: 336)
        ]
        
        let songNameLabelConstraint = [
            songNameLabel.topAnchor.constraint(equalTo: blurView.bottomAnchor, constant: 72),
            songNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            songNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22)
        ]
        
        let artistNameLabelContraint = [
            artistNameLabel.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor, constant: 5),
            artistNameLabel.leadingAnchor.constraint(equalTo: songNameLabel.leadingAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: songNameLabel.trailingAnchor)
        ]
        
        let durationSliderContraint = [
            durationSlider.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor, constant: 30),
            durationSlider.leadingAnchor.constraint(equalTo: songNameLabel.leadingAnchor),
            durationSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            durationSlider.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let leadingDurationLabelContraint = [
            leadingDurationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            leadingDurationLabel.leadingAnchor.constraint(equalTo: durationSlider.leadingAnchor),
        ]
        
        let trailingDurationLabelContraint = [
            trailingDurationLabel.topAnchor.constraint(equalTo: leadingDurationLabel.topAnchor),
            trailingDurationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ]
        
        let previousButtonConstraints = [
            previousButton.topAnchor.constraint(equalTo: leadingDurationLabel.bottomAnchor, constant: 77),
            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 123),
            previousButton.widthAnchor.constraint(equalToConstant: 24),
            previousButton.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        let playButtonContraints = [
            playButton.topAnchor.constraint(equalTo: leadingDurationLabel.bottomAnchor, constant: 50),
            playButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let pauseButtonContraints = [
            pauseButton.topAnchor.constraint(equalTo: leadingDurationLabel.bottomAnchor, constant: 50),
            pauseButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 20),
            pauseButton.widthAnchor.constraint(equalToConstant: 80),
            pauseButton.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let nextButtonConstraints = [
            nextButton.topAnchor.constraint(equalTo: previousButton.topAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20),
            nextButton.widthAnchor.constraint(equalTo: previousButton.widthAnchor),
            nextButton.heightAnchor.constraint(equalTo: previousButton.heightAnchor)
        ]
        
        let carouselConstraints = [
            carousel.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            carousel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carousel.widthAnchor.constraint(equalToConstant: 309),
            carousel.heightAnchor.constraint(equalToConstant: 309)
        ]
        
        NSLayoutConstraint.activate(blurViewConstraints)
        NSLayoutConstraint.activate(songNameLabelConstraint)
        NSLayoutConstraint.activate(artistNameLabelContraint)
        NSLayoutConstraint.activate(durationSliderContraint)
        NSLayoutConstraint.activate(leadingDurationLabelContraint)
        NSLayoutConstraint.activate(trailingDurationLabelContraint)
        NSLayoutConstraint.activate(previousButtonConstraints)
        NSLayoutConstraint.activate(playButtonContraints)
        NSLayoutConstraint.activate(pauseButtonContraints)
        NSLayoutConstraint.activate(nextButtonConstraints)
        NSLayoutConstraint.activate(carouselConstraints)
    }
    
//    MARK: PlayMedia Method
    
    func playMedia(name:String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.delegate = self
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
//    MARK: Auxiliary Methods
    
    func timers() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        durationSlider.maximumValue = Float(player.duration)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.nextSong()
        } else {
            return
        }
    }
    
    func togglePlayPauseButtons() {
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
//    MARK: Selectors
    
    @objc private func updateTime() {
        let currentTime = Int(player.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime - minutes * 60
        
        leadingDurationLabel.text = NSString(format: "%02d:%02d", minutes,seconds) as String
        durationSlider.maximumValue = Float(player.duration)
    }
    
    @objc private func updateSlider() {
        durationSlider.value = Float(player.currentTime)
    }
    
    @objc func playSong() {
        if isPlayed {
            player.play()
            isPlayed.toggle()
            togglePlayPauseButtons()
        } else {
            playMedia(name: songs[currentSong].media)
            updateTime()
            timers()
            trailingDurationLabel.text = songs[currentSong].duration
            togglePlayPauseButtons()
        }
    }
    
    @objc func pauseSong() {
        player.pause()
        updateTime()
        isPlayed.toggle()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @objc func scrubMedia() {
        player.stop()
        player.currentTime = TimeInterval(durationSlider.value)
        player.prepareToPlay()
        player.play()
    }
    
    @objc func nextSong() {
        if currentSong != songs.count - 1 {
            player.delegate = self
            currentSong += 1
            carousel.currentItemIndex = currentSong
            playMedia(name: songs[currentSong].media)
            trailingDurationLabel.text = songs[currentSong].duration
            timers()
            togglePlayPauseButtons()
            artistNameLabel.text = songs[currentSong].artistName
            songNameLabel.text = songs[currentSong].songName
        } else {
            return
        }
    }
    
    @objc func previousSong() {
        if currentSong != 0 {
            currentSong -= 1
            carousel.currentItemIndex = currentSong
            playMedia(name: songs[currentSong].media)
            trailingDurationLabel.text = songs[currentSong].duration
            togglePlayPauseButtons()
            artistNameLabel.text = songs[currentSong].artistName
            songNameLabel.text = songs[currentSong].songName
        } else {
            return
        }
    }
}

