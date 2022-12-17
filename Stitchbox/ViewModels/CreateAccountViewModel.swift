//
//  CreateAccountViewModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 16/12/2022.
//

import RxSwift

class CreateAccountViewModel: ViewModelProtocol {
  // MARK: Struct Declaration
  struct Input {}
  
  struct Action {}
  
  struct Output {}
  
  // MARK: Variable Declaration
  let input: Input
  let action: Action
  let output: Output
  
  // MARK: Subject Instantiation
  private let disposeBag = DisposeBag()
  
  init() {
    input = Input()
    action = Action()
    output = Output()
  }
}
