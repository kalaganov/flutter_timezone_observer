import Flutter
import UIKit

/**
 * [FlutterPlugin] for the flutter_timezone_observer package.
 *
 * This class handles the native iOS implementation for fetching the
 * current timezone and listening for timezone changes.
 */
public class FlutterTimezoneObserverPlugin: NSObject, FlutterPlugin {

    private var timezoneStreamHandler: TimezoneStreamHandler?

    private let METHOD_CHANNEL_NAME = "flutter_timezone_observer/methods"
    private let EVENT_CHANNEL_NAME = "flutter_timezone_observer/events"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterTimezoneObserverPlugin()

        let methodChannel = FlutterMethodChannel(name: instance.METHOD_CHANNEL_NAME,
                                                 binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(name: instance.EVENT_CHANNEL_NAME,
                                               binaryMessenger: registrar.messenger())

        instance.timezoneStreamHandler = TimezoneStreamHandler()
        eventChannel.setStreamHandler(instance.timezoneStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getLocalTimezone" {
            let timezone = TimeZone.current.identifier
            result(timezone)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

/**
 * A dedicated [FlutterStreamHandler] for timezone change events.
 *
 * This class manages the lifecycle of the event stream, listening for
 * [NSSystemTimeZoneDidChange] notifications.
 */
class TimezoneStreamHandler: NSObject, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTimezoneChanged),
            name: NSNotification.Name.NSSystemTimeZoneDidChange,
            object: nil
        )
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        self.eventSink = nil
        return nil
    }

    @objc func onTimezoneChanged(notification: NSNotification) {
        let timezone = TimeZone.current.identifier
        self.eventSink?(timezone)
    }
}