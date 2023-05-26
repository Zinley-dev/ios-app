//
//  ContactUsViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/24/23.
//

import UIKit
import RxSwift
import RxRelay
import ObjectMapper

class ContactUsViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
    }
    
    struct Action {
        var submit: AnyObserver<([UIImage], String)>
    }
    
    struct Output {
        var errorsObservable: Observable<String>
        var successObservable: Observable<String>
    }
    private let errorsSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<String>()
    private let submitSubject = PublishSubject<([UIImage], String)>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
        )
        
        action = Action(
            submit: submitSubject.asObserver()
        )
        
        output = Output(
            errorsObservable: errorsSubject.asObservable(),
            successObservable: successSubject.asObservable()
        )
        
        logic()
    }
    
    func logic() {
        submitSubject.subscribe{(images, content) in
            APIManager.shared.uploadContact(images: images, content: content) {
                result in switch result {
                case .success(let response):
                    print(response)
                    self.successSubject.onNext("Successfully sent replies")
                case .failure(let error):
                    print(error)
                    self.errorsSubject.onNext("Cannot send replies")
                }
            }
        }.disposed(by: disposeBag)
    }
    
}
