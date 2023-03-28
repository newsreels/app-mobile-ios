//
//  Cache.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/22/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

/**
 Sample Code for setting up persistent Caches
 let cache: Cache<String, Data> = {
    let cacheFileName = "cached_images"
    // Fetch stored first
    let storedCache = Cache<String, Data>.fetchStoredCache(fileName: cacheFileName)
    // If there's a stored cache, use that instantiation else, create a new one.
    return storedCache ?? Cache<String, Data>(persists: true, cacheFileName: cacheFileName)
 }()
 */
final class Cache<Key: Hashable, Value> {
    
    fileprivate var wrapped = NSCache<WrappedKey, Entry>()
    fileprivate let dateProvider: () -> Date
    fileprivate let entryLifetime: TimeInterval
    fileprivate let keyTracker = KeyTracker()
    fileprivate var fileName: String? = nil

    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60,
         maximumEntryCount: Int = 50,
         clearsOnLogout: Bool = true) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
        
        if clearsOnLogout {
            CacheCleaner.addCleaner { [weak self] in
                self?.wrapped.removeAllObjects()
            }
        }
    }
    convenience init(dateProvider: @escaping () -> Date = Date.init,
                     entryLifetime: TimeInterval = 12 * 60 * 60,
                     maximumEntryCount: Int = 50,
                     clearsOnLogout: Bool = true,
                     persists: Bool,
                     cacheFileName: String) {
        self.init(dateProvider: dateProvider, entryLifetime: entryLifetime, maximumEntryCount: maximumEntryCount, clearsOnLogout: clearsOnLogout)
        if persists {
            fileName = cacheFileName
        }
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
    
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}
extension Cache: Codable where Key: Codable, Value: Codable {
    
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
    
    func saveToDisk(using fileManager: FileManager = .default) throws {
        if let fileName = fileName {
            let folderURLs = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )

            let fileURL = folderURLs[0].appendingPathComponent(fileName + ".cache")
            let data = try JSONEncoder().encode(self)
            try data.write(to: fileURL)
        } else {
            print("ERROR || FileName was not set, save to disk failed")
        }
    }
    
    static func fetchStoredCache(fileName: String) -> Self? {
        let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                            .userDomainMask,
                                                            true)
        let filePath: String?
        if let firstDirectory = directory[safe: 0],
           var pathURL = URL(string: firstDirectory) {
            pathURL.appendPathComponent(fileName + ".cache")
            filePath = pathURL.absoluteString
        } else {
            filePath = nil
        }
        
        guard let filePath = filePath
        else { return nil }
        
        do {
            let savedString = try String(contentsOfFile: filePath)
            if let data = savedString.data(using: .utf8) {
                let selfInstance = try JSONDecoder().decode(Self.self, from: data)
                selfInstance.fileName = fileName
                return selfInstance
            }
        } catch {
            print("Error reading saved file")
        }
        return nil
    }
}

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
    
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

struct CacheCleaner {
    
    private static var cleanerFunctions: [()->()] = []
    
    // restricted to this file only so it will not be misused
    fileprivate static func addCleaner(_ function: @escaping ()->()) {
        cleanerFunctions.append(function)
    }
    
    static func executeCleanup() {
        cleanerFunctions.forEach{ $0() }
        cleanerFunctions.removeAll()
    }
}
