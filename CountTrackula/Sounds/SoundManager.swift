import AVFAudio

class SoundManager: NSObject {
    static let shared = SoundManager()
    
    var useSound: Bool {
        Analytics.shared.isDevelopment
    }
    var soundEffectsPlayers: [AVAudioPlayer] = []
    
    func playSoundEffect(named soundName: String) {
        if (!self.useSound) { return }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "aif"),
            let player = try? AVAudioPlayer(contentsOf: url) else {
            print("Error: Could not load sound effect \(soundName)")
            return
        }
        player.delegate = self
        player.prepareToPlay()
        player.play()
        soundEffectsPlayers.append(player)
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        soundEffectsPlayers.removeAll { $0 == player }
    }
}

