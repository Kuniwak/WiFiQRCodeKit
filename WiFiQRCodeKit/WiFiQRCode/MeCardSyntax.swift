let ssidHeaderName = "S"
let encryptionTypeHeaderName = "T"
let passwordHeaderName = "P"
let hiddenHeaderName = "H"

let doubleQuote = "\"".first!
let terminator = ";".first!
let separator = ":".first!
let comma = ",".first!
let backslash = "\\".first!

let meCardEscapingPrefix = backslash
let meCardSpecialCharacters = Set([
    doubleQuote,
    terminator,
    separator,
    comma,
    backslash,
])
