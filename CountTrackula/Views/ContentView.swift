import SwiftUI
import SwiftData
import Vision

struct ContentView: View {
    @State var camera: CameraHandler = CameraHandler()
    @State private var isPresentingSettings: Bool = false
    
    var body: some View {
        ZStack {
            VideoFeedView(isPresentingSettings: $isPresentingSettings)
            
            Color.black
                .opacity(self.isPresentingSettings ? 0.5 : 0.0)
                .allowsHitTesting(self.isPresentingSettings)
                .onTapGesture {
                    self.isPresentingSettings.toggle()
                }
            
            HStack(spacing: 0) {
                Spacer()
                VStack {
                    IconButtonView(icon: "gearshape.fill")
                        .onTapGesture {
                            self.isPresentingSettings.toggle()
                        }
                }
                .padding(.leading, 16)
                SettingsView()
                    .frame(width: 500)
            }
            .offset(x: self.isPresentingSettings ? 0 : 500)
        }
        .environment(camera)
        .animation(.default, value: self.isPresentingSettings)
        .ignoresSafeArea()
        .task {
            Analytics.shared.trackSystemEvent(description: "App Launch")
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#Preview {
    Settings.analyticsInstance.value = "xcode preview"
    Settings.analyticsIsDevelopment.value = true
    Settings.analyticsIsDisabled.value = true
    
    return ContentView()
}
