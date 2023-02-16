import SwiftUI

enum Language : String, CaseIterable, Identifiable {
    case Arabic
    case Chinese
    case Czech
    case Danish
    case Dutch
    case English
    case French
    case German
    case Greek
    case Hebrew
    case Hindi
    case Icelandic
    case Indonesian
    case Irish
    case Italian
    case Japanese
    case Korean
    case Latin
    case Norwegian
    case Persian
    case Polish
    case Portuguese
    case Russian
    case Spanish
    case Swedish
    case Tagalog
    case Tahitian
    case Thai
    case Turkish

//    case Arabic     = "ar"
//    case Chinese    = "zh"
//    case Czech      = "cs"
//    case Danish     = "da"
//    case Dutch      = "nl"
//    case English    = "en"
//    case French     = "fr"
//    case German     = "de"
//    case Greek      = "el"
//    case Hebrew     = "he"
//    case Hindi      = "hi"
//    case Icelandic  = "is"
//    case Indonesian = "id"
//    case Irish      = "ga"
//    case Italian    = "it"
//    case Japanese   = "ja"
//    case Korean     = "ko"
//    case Latin      = "la"
//    case Norwegian  = "no"
//    case Persian    = "fa"
//    case Polish     = "pl"
//    case Portuguese = "pt"
//    case Russian    = "ru"
//    case Spanish    = "es"
//    case Swedish    = "sv"
//    case Tagalog    = "tl"
//    case Tahitian   = "ty"
//    case Thai       = "th"
//    case Turkish    = "tr"
    
    var id: Self {self}

    func isoCode() -> String {
        switch self {
        case .Arabic:
            return "ar"
        case .Chinese:
            return "zh"
        case .Czech:
            return "cs"
        case .Danish:
            return "da"
        case .Dutch:
            return "nl"
        case .English:
            return "en"
        case .French:
            return "fr"
        case .German:
            return "de"
        case .Greek:
            return "el"
        case .Hebrew:
            return "he"
        case .Hindi:
            return "hi"
        case .Icelandic:
            return "is"
        case .Indonesian:
            return "id"
        case .Irish:
            return "ga"
        case .Italian:
            return "it"
        case .Japanese:
            return "ja"
        case .Korean:
            return "ko"
        case .Latin:
            return "la"
        case .Norwegian:
            return "no"
        case .Persian:
            return "fa"
        case .Polish:
            return "pl"
        case .Portuguese:
            return "pt"
        case .Russian:
            return "ru"
        case .Spanish:
            return "es"
        case .Swedish:
            return "sv"
        case .Tagalog:
            return "tl"
        case .Tahitian:
            return "ty"
        case .Thai:
            return "th"
        case .Turkish:
            return "tr"
        }
    }
}
