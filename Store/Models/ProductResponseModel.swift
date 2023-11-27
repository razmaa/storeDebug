//
//  ProductResponseModel.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import Foundation

struct ProductResponseModel: Decodable { //Changed to decodable
    let products: [ProductModel]
    let total: Int
    let skip: Int
    let limit: Int
}
