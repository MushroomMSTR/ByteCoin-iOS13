//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//
	
	import Foundation

	protocol CoinManagerDelegate {
		func didUpdatePrice(price: String, currency: String)
		func didFailWithError(error: Error)
	}

	struct CoinManager {
		
		var delegate: CoinManagerDelegate?
		
		let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
		let apiKey = ApiKey.api // I use the api from this site https://www.coinapi.io . In the project, you will need to replace let apiKey = ApiKey.api with your api
		
		let currencyArray = ["EUR","GBP","JPY","PLN","UAH","USD"]
		
		func getCoinPrice(for currency: String) {
			
			let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
			print(urlString)
			
			if let url = URL(string: urlString) {
				
				let session = URLSession(configuration: .default)
				let task = session.dataTask(with: url) { (data, response, error) in
					if error != nil {
						self.delegate?.didFailWithError(error: error!)
						return
					}
					
					if let safeData = data {
						if let bitcoinPrice = self.parseJSON(safeData) {
							let priceString = String(format: "%.2f", bitcoinPrice)
							self.delegate?.didUpdatePrice(price: priceString, currency: currency)
						}
					}
				}
				task.resume()
			}
		}
		
		func parseJSON(_ data: Data) -> Double? {
			
			let decoder = JSONDecoder()
			do {
				let decodedData = try decoder.decode(CoinData.self, from: data)
				let lastPrice = decodedData.rate
				print(lastPrice)
				return lastPrice
				
			} catch {
				delegate?.didFailWithError(error: error)
				return nil
			}
		}
		
	}
