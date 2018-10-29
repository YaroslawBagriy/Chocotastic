/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  
  let disposeBag = DisposeBag()
  
  //MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()

  }
  
  //MARK: Rx Setup
  
  private func setupCartObserver() {
    // Grab the shopping carts observed value
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: { // Subscribe to any changes, and do the foloowing when here is a change
        chocolates in
        self.cartButton.title = "\(chocolates.count) 🍫"
      })
      .addDisposableTo(disposeBag) // Add the observer to the DisposeBag
  }
  
  private func setupCellConfiguration() {
    // Call bindTo to associate the europeanChocolates to each row in the TableView
    europeanChocolates
      .bindTo(tableView
        .rx // Access the RxCocoa extention for TableView
        .items(cellIdentifier: ChocolateCell.Identifier,
               cellType: ChocolateCell.self)) { // This allows the Rx framework to call the dequeuing methods that would normally be called if your table view still had its original delegates.
                row, chocolate, cell in
                cell.configureWithChocolate(chocolate: chocolate) // Configure the TableView Cell
      }
      .addDisposableTo(disposeBag) // Add to the DisposeBag
  }
  
  private func setupCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self) // An Observable you can use to watch information about when model objects are selected.
      .subscribe(onNext: { // Subscribe to that observable
        chocolate in
        ShoppingCart.sharedCart.chocolates.value.append(chocolate) // Add selected chocolate to the cart
        
        // Make sure the tapped row is deselected
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
      .addDisposableTo(disposeBag) //5
  }
  
}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  
  enum SegueIdentifier: String {
    case
    GoToCart
  }
}
