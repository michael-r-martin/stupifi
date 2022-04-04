//
//  NFCProtocols.swift
//  stupifi
//
//  Created by Michael Martin on 02/04/2022.
//

import Foundation

protocol CustomNFCDelegate {
    func sessionDidFail()
    
    func didCompleteSuccessfulSession(sessionType: NFCType)
}

enum NFCType {
    case read
    case write
}
