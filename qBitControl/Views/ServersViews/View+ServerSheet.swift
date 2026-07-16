import SwiftUI

extension View {
    func serverSheetAndAlert(
        activeSheet: Binding<ActiveSheet?>,
        isTroubleConnecting: Binding<Bool>
    ) -> some View {
        self
            .sheet(item: activeSheet) { item in
                switch item {
                case .add:
                    ServerAddView()
                case .edit(let serverId):
                    ServerAddView(editServerId: serverId)
                }
            }
            .alert(isPresented: isTroubleConnecting) {
                Alert(
                    title: Text("Couldn't connect to the server."),
                    message: Text("Check if the URL, username and password is correct. Make sure local network access is enabled:\nSettings > Privacy & Security > Local Network > qBitControl")
                )
            }
    }
}
