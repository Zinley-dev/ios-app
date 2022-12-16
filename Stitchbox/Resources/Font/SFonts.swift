
import UIKit
import SwiftUI

#if canImport(SwiftUI) && DEBUG

@available(iOS 13, *)
struct FontView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            VStack(alignment: .leading, spacing: 8.0) {
              Text("Title 1")
              .font(Font.custom("Helvetica", size: 28.0, relativeTo: .title))
              Text("Title 2")
              .font(Font.custom("Helvetica", size: 22.0, relativeTo: .title2))
              Text("Title 3")
              .font(Font.custom("Helvetica", size: 20.0, relativeTo: .title3))
              Text("Headline")
              .font(Font.custom("Helvetica", size: 17.0, relativeTo: .headline))
              Text("Subheadline")
              .font(Font.custom("Helvetica", size: 15.0, relativeTo: .subheadline))
              Text("Body")
              .font(Font.custom("Helvetica", size: 17.0, relativeTo: .body))
              Text("Callout")
              .font(Font.custom("Helvetica", size: 16.0, relativeTo: .callout))
              Text("Footnote")
              .font(Font.custom("Helvetica", size: 13.0, relativeTo: .footnote))
              Text("Caption 1")
              .font(Font.custom("Helvetica", size: 12.0, relativeTo: .caption))
              Text("Caption 2")
              .font(Font.custom("Helvetica", size: 11.0, relativeTo: .caption2))
            }
        }
    }
}
#endif
