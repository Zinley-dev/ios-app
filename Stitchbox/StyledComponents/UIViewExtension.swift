//
//  UIViewExtension.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/25/22.
//

import Foundation
import UIKit
import SwiftUI

extension UIView {
    // enable preview for UIKit
    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
    @available(iOS 13, *)
    private struct Preview: UIViewRepresentable {
        typealias UIViewType = UIView
        let view: UIView
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(view: self)
    }
}

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {

        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}
