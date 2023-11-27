//
//  ProductsListViewController.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import UIKit

final class ProductsListViewController: UIViewController {
    
    //MARK: - Properties
    private let productsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .purple
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .white
        return indicator
    }()
    
    private let totalPriceLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "total: 0$"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    private let productsViewModel = ProductsListViewModel()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProductsViewModel()
        productsViewModel.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    //MARK: setup UI
    private func setupUI() { //private
        view.backgroundColor = .orange
        setupTableView()
        setupIndicator()
        setupTotalPriceLbl()
    }
    
    //MARK: - Private Methods
    private func setupTableView() { //private
        view.addSubview(productsTableView)
        
        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        productsTableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        productsTableView.delegate = self  //Added dataSource and delegate
        productsTableView.dataSource = self
    }
    
    private func setupIndicator() { //private
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTotalPriceLbl() { //private
        view.addSubview(totalPriceLbl)
        
        NSLayoutConstraint.activate([
            totalPriceLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalPriceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalPriceLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: Setup delegates
    private func setupProductsViewModel() {
        productsViewModel.delegate = self
    }
}

//MARK: - TableView DataSource/Delegate
extension ProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productsViewModel.products?.count ?? 0    //Changed number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard 
            let currentProduct = productsViewModel.products?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.reload(with: currentProduct)
        return cell
    }
}
//MARK: - ViewModel Delegate
extension ProductsListViewController: ProductsListViewModelDelegate {
    
    func productsAmountChanged() {
        totalPriceLbl.text = "Total price: \(productsViewModel.totalPrice ?? 0) $"
    }
    
    func productsFetched() {
        DispatchQueue.main.async {  //Added to main thread
            self.activityIndicator.stopAnimating()
            self.productsTableView.reloadData()
        }
    }
    
    func showError(_ error: Error) {
        print("error")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - Cell Delegate
extension ProductsListViewController: ProductCellDelegate {
    
    func removeProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.removeProduct(at: indexPath.row) // + 1 is needless
            productsTableView.reloadRows(at: [indexPath], with: .automatic) //reload row
        }
    }
    
    func addProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.addProduct(at: indexPath.row) // + 1 is needless
            productsTableView.reloadRows(at: [indexPath], with: .automatic) //reload row
        }
    }
}


