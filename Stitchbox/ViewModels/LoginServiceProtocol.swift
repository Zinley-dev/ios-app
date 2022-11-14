//
//  LoginServiceProtocol.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift
protocol LoginServiceProtocol {
    func signIn(with credentials: Credentials) -> Observable<Account>
}
