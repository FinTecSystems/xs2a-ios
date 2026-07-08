import UIKit
@testable import XS2AiOS

let snapshotThemes: [(name: String, style: XS2A.StyleProvider)] = [
    ("defaultLight", XS2A.StyleProvider()),
    ("defaultDark", darkStyleProvider)
]

private let darkStyleProvider = XS2A.StyleProvider(
    tintColor: UIColor(red: 100/255, green: 160/255, blue: 175/255, alpha: 1),
    logoVariation: .white,
    backgroundColor: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1),
    textColor: .white,
    errorColor: UIColor(red: 1, green: 69/255, blue: 58/255, alpha: 1),
    inputBackgroundColor: UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1),
    inputBorderRadius: 6,
    inputBorderColor: .clear,
    inputBorderWidth: 0,
    inputBorderWidthActive: 2,
    inputTextColor: .white,
    placeholderColor: UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
    buttonBorderRadius: 6,
    submitButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 100/255, green: 160/255, blue: 175/255, alpha: 1)
    ),
    backButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    abortButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    restartButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    alertBorderRadius: 6,
    errorStyle: XS2A.AlertStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 1, green: 69/255, blue: 58/255, alpha: 1)
    ),
    warningStyle: XS2A.AlertStyle(
        textColor: .black,
        backgroundColor: UIColor(red: 1, green: 214/255, blue: 10/255, alpha: 1)
    ),
    infoStyle: XS2A.AlertStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 10/255, green: 132/255, blue: 1, alpha: 1)
    )
)
