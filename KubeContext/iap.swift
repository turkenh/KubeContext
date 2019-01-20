//
//  iap.swift
//  KubeContext
//
//  Created by Hasan Turken on 21.01.2019.
//  Copyright © 2019 Turken, Hasan. All rights reserved.
//

import Foundation
import SwiftyStoreKit

let proProductId = bundleID + ".pro"

func getProduct() {
    SwiftyStoreKit.retrieveProductsInfo([proProductId]) { result in
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            print("Product: \(product.localizedDescription), price: \(priceString)")
        }
        else if let invalidProductId = result.invalidProductIDs.first {
            print("Invalid product identifier: \(invalidProductId)")
        }
        else {
            print("Error: \(String(describing: result.error))")
        }
    }
}
