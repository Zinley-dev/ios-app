//
//  TwoWayBinding.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/19/23.
//

import RxRelay
import RxCocoa
import RxSwift
// Two way binding operator between control property and relay, that's all it takes.
infix operator <-> : DefaultPrecedence

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = relay.bind(to: property)
    let bindToRelay = property
        .subscribe(onNext: { n in
            relay.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToRelay)
}
