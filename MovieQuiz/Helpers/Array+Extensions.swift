import Foundation

//Сабскрипт safe — это функция расширения массива, позволяет безопасно достать элемент из массива.
extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
