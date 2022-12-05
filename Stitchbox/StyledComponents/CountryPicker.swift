//
//  CountryPicker.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/3/22.
//

//
//  SLoading.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 30/11/2022.
//

import Foundation
import UIKit
import SwiftUI
import CountryPickerView

class CountryCodeViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!

        override func viewDidLoad() {
            super.viewDidLoad()

            let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
            phoneNumberField.leftView = cpv
            phoneNumberField.leftViewMode = .always
        }
}

#if canImport(SwiftUI) && DEBUG


struct CountryPickerViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "CountryPicker").view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

@available(iOS 13, *)
struct CountryPickerView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            CountryPickerViewRepresentable()
        }
    }
}
#endif

