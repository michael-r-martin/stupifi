//
//  BalanceFetcher.swift
//  stupifi
//
//  Created by Michael Martin on 24/06/2022.
//

import Foundation

struct BalanceResponse: Codable {
    var balance: String = "0.00"
}

protocol BalanceFetchDelegate {
    func didAttemptFetch(success: Bool)
}

class BalanceFetcher {
    
    let decoder = JSONDecoder()
    
    var fetchedBalance: String = "0.00"
    
    var delegate: BalanceFetchDelegate?
    
    func fetchBalance(walletAddressOrENS: String) {
        var urlComponents = URLComponents(string: "https://ioeth-7yo57vq7xq-nw.a.run.app")
        
        let sentDataQuery = URLQueryItem(name: "walletAddress", value: walletAddressOrENS)
        
        urlComponents?.queryItems = [sentDataQuery]
        
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let serverTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            guard let data = data else {
                print("no data available \(#line)")
                
                self.delegate?.didAttemptFetch(success: false)
                
                return
            }
            
            guard let parsedResponse = self.parseResponse(data: data) else {
                print("no data available \(#line)")
                
                self.delegate?.didAttemptFetch(success: false)
                
                return
            }
            
            let formattedBalance = self.formatBalance(balance: parsedResponse.balance)
            
            self.fetchedBalance = formattedBalance

            self.delegate?.didAttemptFetch(success: true)
        }
        serverTask.resume()
    }
    
    func parseResponse(data: Data) -> BalanceResponse? {
        do {
            let parsedJSON = try decoder.decode(BalanceResponse.self, from: data)
            
            return parsedJSON
        } catch {
            print("error parsing balance: \(error)")
            
            return nil
        }
    }
    
    func formatBalance(balance: String) -> String {
        guard let balanceAsDouble = Double(balance) else { return "0.00" }
        
        let formattedBalance = String(format: "%.3f", balanceAsDouble)
        
        let finalString = "\(formattedBalance) ETH"
        
        return finalString
    }
    
}
