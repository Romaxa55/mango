import SwiftUI
import CodeScanner

struct MGQRCodeScannerView: View {
        
    @Environment(\.dismiss) private var dismiss
    
    let result: Binding<Swift.Result<ScanResult, ScanError>?>
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack {
                    
                    Spacer()
                    
                    CodeScannerView(codeTypes: [.qr]) {
                        result.wrappedValue = $0
                        dismiss()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(16)
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    
                    Spacer()
                    
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("关闭")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(8)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle(Text("扫描二维码"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
