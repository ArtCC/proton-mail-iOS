// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

protocol HasBiometricStatusProvider {
    var biometricStatusProvider: BiometricStatusProvider { get }
}

extension GlobalContainer: HasBiometricStatusProvider {
    var biometricStatusProvider: BiometricStatusProvider {
        biometricStatusProviderFactory()
    }
}

extension UserContainer: HasBiometricStatusProvider {
    var biometricStatusProvider: BiometricStatusProvider {
        globalContainer.biometricStatusProvider
    }
}

protocol HasCleanCache {
    var cleanCache: CleanCache { get }
}

extension GlobalContainer: HasCleanCache {
    var cleanCache: CleanCache {
        cleanCacheFactory()
    }
}

extension UserContainer: HasCleanCache {
    var cleanCache: CleanCache {
        globalContainer.cleanCache
    }
}

protocol HasDarkModeCacheProtocol {
    var darkModeCache: DarkModeCacheProtocol { get }
}

extension GlobalContainer: HasDarkModeCacheProtocol {
    var darkModeCache: DarkModeCacheProtocol {
        darkModeCacheFactory()
    }
}

extension UserContainer: HasDarkModeCacheProtocol {
    var darkModeCache: DarkModeCacheProtocol {
        globalContainer.darkModeCache
    }
}

protocol HasNotificationCenter {
    var notificationCenter: NotificationCenter { get }
}

extension GlobalContainer: HasNotificationCenter {
    var notificationCenter: NotificationCenter {
        notificationCenterFactory()
    }
}

extension UserContainer: HasNotificationCenter {
    var notificationCenter: NotificationCenter {
        globalContainer.notificationCenter
    }
}

protocol HasSaveSwipeActionSettingForUsersUseCase {
    var saveSwipeActionSetting: SaveSwipeActionSettingForUsersUseCase { get }
}

extension GlobalContainer: HasSaveSwipeActionSettingForUsersUseCase {
    var saveSwipeActionSetting: SaveSwipeActionSettingForUsersUseCase {
        saveSwipeActionSettingFactory()
    }
}

extension UserContainer: HasSaveSwipeActionSettingForUsersUseCase {
    var saveSwipeActionSetting: SaveSwipeActionSettingForUsersUseCase {
        globalContainer.saveSwipeActionSetting
    }
}

protocol HasSwipeActionCacheProtocol {
    var swipeActionCache: SwipeActionCacheProtocol { get }
}

extension GlobalContainer: HasSwipeActionCacheProtocol {
    var swipeActionCache: SwipeActionCacheProtocol {
        swipeActionCacheFactory()
    }
}

extension UserContainer: HasSwipeActionCacheProtocol {
    var swipeActionCache: SwipeActionCacheProtocol {
        globalContainer.swipeActionCache
    }
}

protocol HasToolbarCustomizationInfoBubbleViewStatusProvider {
    var toolbarCustomizationInfoBubbleViewStatusProvider: ToolbarCustomizationInfoBubbleViewStatusProvider { get }
}

extension GlobalContainer: HasToolbarCustomizationInfoBubbleViewStatusProvider {
    var toolbarCustomizationInfoBubbleViewStatusProvider: ToolbarCustomizationInfoBubbleViewStatusProvider {
        toolbarCustomizationInfoBubbleViewStatusProviderFactory()
    }
}

extension UserContainer: HasToolbarCustomizationInfoBubbleViewStatusProvider {
    var toolbarCustomizationInfoBubbleViewStatusProvider: ToolbarCustomizationInfoBubbleViewStatusProvider {
        globalContainer.toolbarCustomizationInfoBubbleViewStatusProvider
    }
}

protocol HasBlockedSenderCacheUpdater {
    var blockedSenderCacheUpdater: BlockedSenderCacheUpdater { get }
}

extension UserContainer: HasBlockedSenderCacheUpdater {
    var blockedSenderCacheUpdater: BlockedSenderCacheUpdater {
        blockedSenderCacheUpdaterFactory()
    }
}

protocol HasBlockedSendersPublisher {
    var blockedSendersPublisher: BlockedSendersPublisher { get }
}

extension UserContainer: HasBlockedSendersPublisher {
    var blockedSendersPublisher: BlockedSendersPublisher {
        blockedSendersPublisherFactory()
    }
}

protocol HasContactViewsFactory {
    var contactViewsFactory: ContactViewsFactory { get }
}

extension UserContainer: HasContactViewsFactory {
    var contactViewsFactory: ContactViewsFactory {
        contactViewsFactoryFactory()
    }
}

protocol HasFetchSenderImage {
    var fetchSenderImage: FetchSenderImage { get }
}

extension UserContainer: HasFetchSenderImage {
    var fetchSenderImage: FetchSenderImage {
        fetchSenderImageFactory()
    }
}

protocol HasFetchMessageDetail {
    var fetchMessageDetail: FetchMessageDetail { get }
}

extension UserContainer: HasFetchMessageDetail {
    var fetchMessageDetail: FetchMessageDetail {
        fetchMessageDetailFactory()
    }
}

protocol HasImageProxy {
    var imageProxy: ImageProxy { get }
}

extension UserContainer: HasImageProxy {
    var imageProxy: ImageProxy {
        imageProxyFactory()
    }
}

protocol HasSearchUseCase {
    var messageSearch: SearchUseCase { get }
}

extension UserContainer: HasSearchUseCase {
    var messageSearch: SearchUseCase {
        messageSearchFactory()
    }
}

protocol HasNextMessageAfterMoveStatusProvider {
    var nextMessageAfterMoveStatusProvider: NextMessageAfterMoveStatusProvider { get }
}

extension UserContainer: HasNextMessageAfterMoveStatusProvider {
    var nextMessageAfterMoveStatusProvider: NextMessageAfterMoveStatusProvider {
        nextMessageAfterMoveStatusProviderFactory()
    }
}

protocol HasSettingsViewsFactory {
    var settingsViewsFactory: SettingsViewsFactory { get }
}

extension UserContainer: HasSettingsViewsFactory {
    var settingsViewsFactory: SettingsViewsFactory {
        settingsViewsFactoryFactory()
    }
}

protocol HasSaveToolbarActionSettings {
    var saveToolbarActionSettings: SaveToolbarActionSettings { get }
}

extension UserContainer: HasSaveToolbarActionSettings {
    var saveToolbarActionSettings: SaveToolbarActionSettings {
        saveToolbarActionSettingsFactory()
    }
}

protocol HasSendBugReport {
    var sendBugReport: SendBugReport { get }
}

extension UserContainer: HasSendBugReport {
    var sendBugReport: SendBugReport {
        sendBugReportFactory()
    }
}

protocol HasToolbarActionProvider {
    var toolbarActionProvider: ToolbarActionProvider { get }
}

extension UserContainer: HasToolbarActionProvider {
    var toolbarActionProvider: ToolbarActionProvider {
        toolbarActionProviderFactory()
    }
}

protocol HasToolbarSettingViewFactory {
    var toolbarSettingViewFactory: ToolbarSettingViewFactory { get }
}

extension UserContainer: HasToolbarSettingViewFactory {
    var toolbarSettingViewFactory: ToolbarSettingViewFactory {
        toolbarSettingViewFactoryFactory()
    }
}

protocol HasUnblockSender {
    var unblockSender: UnblockSender { get }
}

extension UserContainer: HasUnblockSender {
    var unblockSender: UnblockSender {
        unblockSenderFactory()
    }
}

