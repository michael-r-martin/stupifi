//
//  NFCHelper.swift
//  stupifi
//
//  Created by Michael Martin on 01/04/2022.
//

import Foundation
import CoreNFC
import UIKit

class NFCHelper: NSObject, NFCNDEFReaderSessionDelegate {
    
    var urlString = "heyyyyy"
    var session: NFCNDEFReaderSession?
    var delegate: CustomNFCDelegate?
    
    func activateSession() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your phone near your friend's 🤝"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("running did detect tags")
        guard let tag = tags.first else {
            print("No NFC tag")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                print("error reading tag", error.localizedDescription)
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    print("error reading tag", error.localizedDescription)
                    session.invalidate()
                    return
                }
                
                switch status {
                case .notSupported:
                    print("tag not supported")
                    session.invalidate()
                case .readWrite:
                    tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: self.urlString)!])) { error in
                        if let error = error {
                            print("error reading tag", error.localizedDescription)
                            session.invalidate()
                            return
                        }
                        
                        print("tag read successfully")
                        session.invalidate()
                        
                        self.delegate?.didCompleteSuccessfulSession(sessionType: .write)
                    }
                case .readOnly:
                    session.invalidate()
                @unknown default:
                    print("unknown case")
                    session.invalidate()
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("running did detect NDEFs")
        DispatchQueue.main.async {
            for message in messages {
                print(message.records)
            }
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("reader session active")
    }
    
    
}
