//
//  SharedKeychain.swift
//  RCRC
//
//  Created by Sagar Tilekar on 30/08/20.
//

import UIKit

class SharedKeychain: NSObject {

    static let sharedInstance = SharedKeychain()

    override init() {
        super.init()
    }

    // Method use for saving data in keychain
    func save(user: String, password: String) -> Bool {

        let saveUserSuccessful: Bool = KeychainWrapper.standard.set(user, forKey: Keychain.kUserKey)
        print("Save was successful: \(saveUserSuccessful)")
        let savePasswordSuccessful: Bool = KeychainWrapper.standard.set(password, forKey: Keychain.kPasswordKey)
        print("Save was successful: \(savePasswordSuccessful)")
        if savePasswordSuccessful == saveUserSuccessful {
            return true
        }
        return false

    }

    // Method use for retrieve data in keychain
    func retrieve() -> [[String: String]] {

        let retrieveUserName: String = KeychainWrapper.standard.string(forKey: Keychain.kUserKey)!
        print("Retrieved Username is: \(retrieveUserName)")
        let retrievePassword: String = KeychainWrapper.standard.string(forKey: Keychain.kPasswordKey)!
        print("Retrieved password is: \(retrievePassword)")
        var userCredentials = [[String: String]]()
        userCredentials.append(["UserName": retrieveUserName])
        userCredentials.append(["UserPassword": retrievePassword])
        // print(userCredentials[0])
        // print(userCredentials[0]["UserName"]!)
        return userCredentials

    }

    // Method use for remove data in keychain
    func remove(keys: [String]) -> Bool {

        let removeUserSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: keys[0])
        print("Remove user is: \(removeUserSuccessful)")
        let removePasswordSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: keys[1])
        print("Remove password is: \(removePasswordSuccessful)")
        if removeUserSuccessful == removePasswordSuccessful {
            return true
        }
        return false

    }
}
