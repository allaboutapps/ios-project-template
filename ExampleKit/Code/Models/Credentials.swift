import Foundation
import KeychainAccess
import ReactiveSwift
import Result

public class Credentials: NSObject, NSCoding, Codable {

    // MARK: Static

    fileprivate static let keychain = Keychain(service: Config.keyPrefix)
    fileprivate static let credentialStorageKey = Config.Keychain.credentialStorageKey
    fileprivate static var cachedCredentials: Credentials?

    fileprivate static var currentCredentialsChangedSignalObserver = Signal<(), NoError>.pipe()
    static var currentCredentialsChangedSignal: Signal<(), NoError> {
        return currentCredentialsChangedSignalObserver.output
    }

    static var currentCredentials: Credentials? {
        get {
            if let credentialsData = keychain[data: credentialStorageKey],
                let credentials = NSKeyedUnarchiver.unarchiveObject(with: credentialsData) as? Credentials, cachedCredentials == nil {
                cachedCredentials = credentials
                return credentials
            } else {
                return cachedCredentials
            }
        }
        set {
            if let credentials = newValue {
                keychain[data: credentialStorageKey] = NSKeyedArchiver.archivedData(withRootObject: credentials)
                cachedCredentials = credentials
            } else {
                cachedCredentials = nil
                _ = try? keychain.remove(credentialStorageKey)
            }
            currentCredentialsChangedSignalObserver.input.send(value: ())
        }
    }

    // MARK: Variables

    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval

    // MARK: Initializers

    init(accessToken: String, refreshToken: String?, expiresIn: TimeInterval?) {
        self.refreshToken = refreshToken ?? ""
        self.accessToken = accessToken
        self.expiresIn = expiresIn ?? NSDate.distantFuture.timeIntervalSinceReferenceDate
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        guard let data = aDecoder.decodeObject(forKey: Config.Keychain.credentialsKey) as? Data else { return nil }
        guard let decoded = try? Decoders.standardJSON.decode(Credentials.self, from: data) else { return nil }
        self.init(accessToken: decoded.accessToken, refreshToken: decoded.refreshToken, expiresIn: decoded.expiresIn)
    }

    // MARK: Encoding

    public func encode(with aCoder: NSCoder) {
        let data = try? JSONEncoder().encode(self)
        aCoder.encode(data, forKey: Config.Keychain.credentialsKey)
    }
}
