//
//  ProductsListViewModel.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import Foundation
import UIKit

protocol ProductsListViewModelDelegate: AnyObject {
    func productsFetched()
    func productsAmountChanged()
    func showError(_ error: Error) // Added func for error and Alert
    func showAlert(title: String, message: String)
}

final class ProductsListViewModel {
    
    weak var delegate: ProductsListViewModelDelegate?
    
    var products: [ProductModel]?
    var totalPrice: Double? { products?.reduce(0) { $0 + $1.price * Double(($1.selectedAmount ?? 0))} }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        NetworkManager.shared.fetchProducts { [weak self] response in
            switch response {
            case .success(let products):
                self?.products = products
                self?.delegate?.productsFetched()
            case .failure(let error):
                //Error handled
                self?.delegate?.showError(error)
                break
            }
        }
    }
    
    func addProduct(at index: Int) {
        let product = products?[index]
        //handle if products are out of stock
        if let stock = product?.stock {
            if stock < 1 {
                delegate?.showAlert(title: "Ups..", message: "Looks like we are out of stock")
            } else {
                
                //product?.selectedAmount = (products?[index].selectedAmount ?? 0 ) + 1 is wrong,
                //we need to update selectedAmount in products array not in product variable, same in removeProducts
                products?[index].selectedAmount = (product?.selectedAmount ?? 0) + 1
                delegate?.productsAmountChanged()
            }
        }
    }
    
    
    func removeProduct(at index: Int) {
        let product = products?[index]
        //handle if selected quantity of product is already 0
        if let selectedAmount = products?[index].selectedAmount  {
            products?[index].selectedAmount = (product?.selectedAmount ?? 0) - 1
            if selectedAmount <= 0 {
                products?[index].selectedAmount = 0
            }
        }
        delegate?.productsAmountChanged()
    }
    
}
