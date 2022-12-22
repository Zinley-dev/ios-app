//
//  SignUpViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 01/12/2022.
//

import UIKit
import RxSwift

class CreateAccountViewController: UIViewController, ControllerType {
  typealias ViewModelType = CreateAccountViewModel
  
  @IBOutlet weak var txtDob: UnderlineTextField!
  // MARK: - Properties
  private var viewModel: ViewModelType! = ViewModelType()
  private let disposeBag = DisposeBag()
  
  // MARK: - UI
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI(with: viewModel)
    bindAction(with: viewModel)
    
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .date
    datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
    datePicker.frame.size = CGSize(width: 0, height: 300)
    datePicker.preferredDatePickerStyle = .wheels
    txtDob.inputView = datePicker
  }
  
  // MARK: - Functions
  func bindUI(with: ViewModelType) {
  }
  
  func bindAction(with viewModel: CreateAccountViewModel) {
  }

  @objc func dateChange(datePicker: UIDatePicker) {
    txtDob.text = formatDate(date: datePicker.date)
  }
  
  func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd yyyy"
    return formatter.string(from: date)
  }
}

extension CreateAccountViewController {
  static func create() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
}
