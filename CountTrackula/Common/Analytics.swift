import Boop

struct Analytics: AnalyticsProtocol {
    let analytics: Boop
    
    static var shared = Analytics()
    
    var application: String {
        didSet {
            analytics.application = application
        }
    }
    var instance: String {
        didSet {
            analytics.instance = instance
        }
    }
    var isDisabled: Bool {
        didSet {
            analytics.isDisabled = isDisabled
        }
    }
    var isDevelopment: Bool {
        didSet {
            analytics.isDevelopment = isDevelopment
        }
    }
    
    init() {
        application = Settings.analyticsApplication.value
        instance = Settings.analyticsInstance.value
        isDevelopment = Settings.analyticsIsDevelopment.value
        isDisabled = Settings.analyticsIsDisabled.value
        
        analytics = Boop(
            application: application,
            instance: instance,
            isDevelopment: isDevelopment,
            isDisabled: isDisabled,
            isSessionTrackingDisabled: true
        )
    }
    
    func trackEntrance(for id: Int) {
        _ = analytics.trackEvent(event: "Person", label: "Enter", value: id, isUserInitiated: false)
    }
    
    func trackExit(for id: Int) {
        _ = analytics.trackEvent(event: "Person", label: "Exit", value: id, isUserInitiated: false)
    }
    
    func trackError(for id: Int, description: String) {
        _ = analytics
            .trackEvent(
                event: "Ignore",
                label: description,
                value: id,
                isUserInitiated: false
            )
    }
    
    func trackSystemEvent(description: String, value: Any? = nil) {
        _ = analytics
            .trackEvent(
                event: "System",
                label: description,
                value: value,
                isUserInitiated: false
            )
    }
}
