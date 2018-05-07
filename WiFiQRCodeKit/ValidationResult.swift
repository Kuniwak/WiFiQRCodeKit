public enum ValidationResult<C, E> {
    case valid(content: C)
    case invalid(because: E)
}
