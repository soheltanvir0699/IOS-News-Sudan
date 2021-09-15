//
//  SessionManager.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//


import UIKit

/*
 * Check is user is connected or not
 */

class SessionManager {
    
    public func setLogin(isLoggedIn: Bool) {
        
        let preferences = UserDefaults.standard
        preferences.set(isLoggedIn, forKey: "isLoggedIn")

    }
    
    public func isLoggedIn() -> Bool {
        let preferences = UserDefaults.standard
        if (preferences.object(forKey: "isLoggedIn") != nil)
        {
            let checkvaluelogin = preferences.bool(forKey: "isLoggedIn")
            if !checkvaluelogin {
                return false
            }
            
            return true
        }
        else
        {
            return false
        }
    }
}
