//
//  ViewController.swift
//  ExAVPlayerLayer
//
//  Created by 김종권 on 2022/04/09.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
  private lazy var videoView: VideoView = {
    let view = VideoView(url: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")
    view.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(view)
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSLayoutConstraint.activate([
      self.videoView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 70),
      self.videoView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -70),
      self.videoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200),
      self.videoView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
    ])
  }
}

final class VideoView: UIView {
  private lazy var videoBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray
    view.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(view)
    return view
  }()
  private lazy var slider: UISlider = {
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(slider)
    return slider
  }()
  
  private var player = AVPlayer()
  private var playerLayer: AVPlayerLayer?
  private let url: String
  
  init(url: String) {
    self.url = url
    super.init(frame: .zero)
    
    NSLayoutConstraint.activate([
      self.videoBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.videoBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.videoBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
      self.videoBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
    ])
    
    NSLayoutConstraint.activate([
      self.slider.topAnchor.constraint(equalTo: self.videoBackgroundView.bottomAnchor, constant: 16),
      self.slider.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
      self.slider.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
    ])
  
    guard let url = URL(string: self.url) else { return }
    let item = AVPlayerItem(url: url)
    self.player.replaceCurrentItem(with: item)
    let playerLayer = AVPlayerLayer(player: self.player)
    playerLayer.frame = self.videoBackgroundView.bounds
    playerLayer.videoGravity = .resizeAspectFill
    self.playerLayer = playerLayer
    self.videoBackgroundView.layer.addSublayer(playerLayer)
    self.player.play()
    
    if self.player.currentItem?.status == .readyToPlay {
      self.slider.minimumValue = 0
      self.slider.maximumValue = Float(CMTimeGetSeconds(item.duration))
    }
    
    self.slider.addTarget(self, action: #selector(changeValue), for: .valueChanged)
    
    let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
    self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] elapsedSeconds in
      let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedSeconds)
      let totalTimeSecondsFloat = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
      print(elapsedTimeSecondsFloat, totalTimeSecondsFloat)
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.playerLayer?.frame = self.videoBackgroundView.bounds
  }
  
  @objc private func changeValue() {
    self.player.seek(to: CMTime(seconds: Double(self.slider.value), preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { _ in
      print("completion")
    })
  }
}
