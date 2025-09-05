import Foundation
import SwiftUI

struct TakeEntryScreen: View {
    @StateObject private var loader: TakeWebLoader

    init(loader: TakeWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            TakeWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                TakeProgressIndicator(value: percent)
            case .failure(let err):
                TakeErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                TakeOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct TakeProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            TakeLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct TakeErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct TakeOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
