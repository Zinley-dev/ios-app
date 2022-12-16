//
//  ModView.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import Foundation
import Cache
import UIKit
import CoreLocation
import Alamofire
import SendBirdCalls
import SendBirdSDK
import SendbirdUIKit
import SendBirdSDK
import CoreMedia
import AsyncDisplayKit
import StoreKit


func blurImage(image:UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale

        let filter = CIFilter(name: "CIBokehBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(30.0, forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage

        var cgImage:CGImage?

        if let asd = outputImage
        {
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }

        if let cgImageA = cgImage
        {
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }

        return nil
    }


var sendbird_applicationID = "B3325F9F-FB59-4A96-823B-95D176E949C8"

extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

}


func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(String(describing: components.year)) years"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour"
        } else {
            return "An hour"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) mins"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 min"
        } else {
            return "A min"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "Just now"
    }
    
}


func timeForReloadScheduler(_ date:Date, numericDates:Bool) -> Int {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return 0
    } else if (components.year! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.month! >= 2) {
        return 0
    } else if (components.month! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.weekOfYear! >= 2) {
        return 0
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.day! >= 2) {
        return 8640
    } else if (components.day! >= 1){
        if (numericDates){
            return 8640
        } else {
            return 8640
        }
    } else if (components.hour! >= 2) {
        return 360
    } else if (components.hour! >= 1){
        if (numericDates){
            return 360
        } else {
            return 360
        }
    } else if (components.minute! >= 2) {
        return 60
    } else if (components.minute! >= 1){
        if (numericDates){
            return 60
        } else {
            return 60
        }
    } else if (components.second! >= 3) {
        return 1
    } else {
        return 1
    }
    
}

func timeForChat(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    let lastMessageDateFormatter = DateFormatter()
    lastMessageDateFormatter.dateStyle = .short
    lastMessageDateFormatter.timeStyle = .none
    
    if (components.year! >= 2) {
        return "\(String(describing: components.year)) years"
    } else if (components.year! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months"
    } else if (components.month! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour"
        } else {
            return "An hour"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) mins"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 min"
        } else {
            return "A min"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "Just now"
    }
    
}

func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}


extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


func applyShadowOnView(_ view:UIView) {

    view.layer.cornerRadius = 8
    view.layer.shadowColor = UIColor.lightGray.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize.zero
    view.layer.shadowRadius = 3

}

private var kAssociationKeyMaxLength: Int = 0


extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}



var pixel_key = "ZFZ7ImsiOiJve3NvYDZKJFY7SjlON01dMWJBIiwidiI6ImY4RkRqIiwiaSI6IjUzIn1yTWZ1"
var env_key = "v9s48ds44jmrgnqgmp666jcpe"
var applicationKey = "2c3ccae1-c080-467b-b989-d1d70aaf159c"
var twApiKey = "4ob6dNOQJPIjz9DQtCiLcD8VY"
var twSecretKey = "mGTOy20I2fhrvvkGsNIRJwKKY7TCywJbrjuaEJexzVrfKeJyqQ"
var should_Play = false
var login_type = ""

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension UIView {

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue

            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }


    func addShadow(shadowColor: CGColor = UIColor.orange.cgColor,
               shadowOffset: CGSize = CGSize(width: 3.0, height: 4.0),
               shadowOpacity: Float = 0.7,
               shadowRadius: CGFloat = 4.5) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

extension UIView {
    func addBottomBorderWithColor(color: UIColor, height: CGFloat, width: CGFloat) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height,
                              width: width, height: height)
        
        
        return border
        
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}


extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970) / 10)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

func formatPoints(num: Double) ->String{
    var thousandNum = num/1000
    var millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum){
            return("\(Int(thousandNum))K")
        }
        return("\(thousandNum.roundToPlaces(places: 1))k")
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum){
            return("\(Int(thousandNum))K")
        }
        return ("\(millionNum.roundToPlaces(places: 1))M")
    }
    if num > 1000000000{
        if(floor(millionNum) == millionNum){
            return("\(Int(thousandNum))M")
        }
        return ("\(millionNum.roundToPlaces(places: 1))B")
    }
    else{
        if(floor(num) == num){
            return ("\(Int(num))")
        }
        return ("\(num)")
    }

}



func getCurrentMillis()->Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 120, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"Roboto-Regular",size: 15)!
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 120, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"Roboto-Regular",size: 15)!
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
       
    }

    func restore() {
        self.backgroundView = nil
    }
    
    
    
}



func calculateMedian(array: [Int]) -> Double {
    // Array should be sorted
    let sorted = array.sorted()
    let length = array.count
    
    // handle when count of items is even
    if (length % 2 == 0) {
        return (Double(sorted[length / 2 - 1]) + Double(sorted[length / 2])) / 2.0
    }
    
    // handle when count of items is odd
    return Double(sorted[length / 2])
}


extension UINavigationBar {

    @IBInspectable var bottomBorderColor: UIColor {
        get {
            return self.bottomBorderColor;
        }
        set {
            let bottomBorderRect = CGRect.zero;
            let bottomBorderView = UIView(frame: bottomBorderRect);
            bottomBorderView.backgroundColor = newValue;
            addSubview(bottomBorderView);

            bottomBorderView.translatesAutoresizingMaskIntoConstraints = false;

            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 1));
        }

    }

}

extension Array where Element : Equatable  {
    public mutating func removeObject(_ item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /*
    subscript (exists index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
     */
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}


extension UINavigationController {

    func popBack(_ nb: Int) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < nb else {
            self.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
            return
        }
    }

    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        var viewControllers: [UIViewController] = self.viewControllers
        viewControllers = viewControllers.reversed()
        for currentViewController in viewControllers {
            if currentViewController .isKind(of: toControllerType) {
                self.popToViewController(currentViewController, animated: true)
                break
            }
        }
    }

 }

extension UIButton {
    
    func beat() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        layer.add(pulse, forKey: nil)
    
    
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.9
        animation.values = [-5.0, 5.0, -5.0, 5.0, -5.0, 2.0, -1.0, 1.0, 0.0 ]
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shake")
    }
    
    
    
    
    func removeAnimation() {
        
        layer.removeAllAnimations()
        
    }

}

@IBDesignable extension UIView {
    @IBInspectable var borderColors: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidths: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
}


@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable
class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}

extension String {
    func findMHashtagText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{L}\\p{N}]*)", options: [.useUnicodeWordBoundaries, .caseInsensitive])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
    
    func findMentiontagText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(@[a-zA-Z0-9_\\p{L}\\p{N}]*)", options: [.useUnicodeWordBoundaries, .caseInsensitive])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}



func findUserIndexFromArray(userUID: String, arr: [String]) -> Int {
    
    var count = 0
    for item in arr {
        
        
        if item == userUID {
            return count
        }
        
        count+=1
        
    }
    
    return count
    
}

extension String{

    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)

        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

}

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    
    return false
}

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        let custom: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 13)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let subtitleString = NSMutableAttributedString(string: subtitle!, attributes: custom)
        
        
        alert.setValue(subtitleString, forKey: "attributedMessage")
        
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showCodeDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        let custom: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 13)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let subtitleString = NSMutableAttributedString(string: subtitle!, attributes: custom)
        
        
        alert.setValue(subtitleString, forKey: "attributedMessage")
        
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action:UIAlertAction) in
            
            
            actionHandler?("Skip Code")
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

func getReadableDate(timeStamp: TimeInterval) -> String? {
    let date = Date(timeIntervalSince1970: timeStamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .long
    dateFormatter.dateStyle = .short
    return dateFormatter.string(from: date)
}

func dateFallsInCurrentWeek(date: Date) -> Bool {
    let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
    let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
    return (currentWeek == datesWeek)
}


extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
    
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}


extension UITableViewRowAction {

  func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, iconSizePercentage: CGFloat)
  {
    let iconHeight = cellHeight * iconSizePercentage
    let margin = (cellHeight - iconHeight) / 2 as CGFloat

    UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
    let context = UIGraphicsGetCurrentContext()

    backColor.setFill()
    context!.fill(CGRect(x:0, y:0, width:cellHeight, height:cellHeight))

    iconImage.draw(in: CGRect(x: margin, y: margin, width: iconHeight, height: iconHeight))

    let actionImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundColor = UIColor.init(patternImage: actionImage!)
  }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}


extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
}


extension CGFloat {
    func toInt() -> Int? {
        if self > CGFloat(Int.min) && self < CGFloat(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}




extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }

    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}


protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)

        // set boundry and alpha
        //effectView.frame = self.bounds
        //effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha

        self.addSubview(effectView)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
    }
}

enum AppStoreReviewManager {
  static func requestReviewIfAppropriate() {
      SKStoreReviewController.requestReview()
  }
}

// Conformance
extension UIView: Bluring {}
