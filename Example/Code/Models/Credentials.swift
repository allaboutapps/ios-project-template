import Foundation
import KeychainAccess
import ReactiveMapper
import Mapper
import ReactiveSwift
import Result

class Credentials: NSObject, NSCoding, Mappable {
    
    fileprivate static let keychain = Keychain(service: Config.Keychain.Service)
    fileprivate static let credentialStorageKey = Config.Keychain.CredentialsStorageKey
    fileprivate static var cachedCredentials: Credentials?
    
    fileprivate static var currentCredentialsChangedSignalObserver = Signal<(), NoError>.pipe()
    static var currentCredentialsChangedSignal: Signal<(), NoError> {
        return currentCredentialsChangedSignalObserver.0
    }
    
    static var currentCredentials: Credentials? {
        get {
            if let credentialsData = keychain[data: credentialStorageKey], let credentials = NSKeyedUnarchiver.unarchiveObject(with: credentialsData) as? Credentials, cachedCredentials == nil {
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
            currentCredentialsChangedSignalObserver.1.send(value: ())
        }
    }
    
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
    
    init(accessToken: String, refreshToken: String?, expiresIn: TimeInterval?) {
        self.refreshToken = refreshToken ?? ""
        self.accessToken = accessToken
        self.expiresIn = expiresIn ?? NSDate.distantFuture.timeIntervalSinceReferenceDate
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let credentialData: NSDictionary = aDecoder.decodeObject(forKey: "credentials") as? NSDictionary, let decodedCredentials: Credentials = Credentials.from(credentialData) {
            self.init(accessToken: decodedCredentials.accessToken, refreshToken: decodedCredentials.refreshToken, expiresIn: decodedCredentials.expiresIn)
        } else {
            return nil
        }
    }
    
    required init(map: Mapper) throws {
        self.accessToken = try map.from("accessToken")
        self.refreshToken = map.optionalFrom("refreshToken") ?? ""
        self.expiresIn = try map.from("expiresIn")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(encode(), forKey: "credentials")
    }
    
}

extension Credentials: Encodeable {
    func encode() -> [String : Any] {
        return [
            "accessToken":  accessToken,
            "refreshToken": refreshToken,
            "expiresIn":   expiresIn
        ]
    }
}
