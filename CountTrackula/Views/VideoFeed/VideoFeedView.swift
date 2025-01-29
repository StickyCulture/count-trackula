import SwiftUI

struct VideoFeedView: View {
    // disable view removal during airplay
    @Environment(\.isSceneCaptured) var isSceneCaptured: Bool
    @Environment(CameraHandler.self) var camera: CameraHandler
    @Binding var isPresentingSettings: Bool
    
    let idleInterval: TimeInterval = 20.0
    let maxIdleTimeout: TimeInterval = 60.0
    
    @State private var idleCount: TimeInterval = 0.0
    @State private var timer: Timer? = nil
    
    var breakIdleGesture: some Gesture {
        DragGesture(minimumDistance: 0).onEnded { _ in
            self.idleCount = 0
        }
    }

    var body: some View {
        ZStack {
            Color.black
            
            if self.idleCount < self.maxIdleTimeout || isSceneCaptured {
                HStack {
                    FrameView(image: camera.imageFrame)
                        .overlay {
                            BodiesView(bodies: camera.tracker.bodies)
                            WireframeView()
                                .clipped()
                        }
                        .aspectRatio(1.33, contentMode: .fit)
                    if self.isPresentingSettings {
                        Spacer()
                    }
                }
                .onAppear {
                    // checking for idleness
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.idleInterval, repeats: true) { _ in
                        self.idleCount += self.idleInterval
                    }
                }
                .onDisappear {
                    // is considered idle, so hide the display of things
                    self.timer?.invalidate()
                    self.timer = nil
                    self.isPresentingSettings = false
                }
            }
        }
        .gesture(breakIdleGesture)
    }
}

#Preview {
    @State var isPresentingSettings = false
    @State var camera = CameraHandler()
    
    return VideoFeedView(isPresentingSettings: $isPresentingSettings)
        .environment(camera)
}
