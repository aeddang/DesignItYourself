
import SwiftUI
import Foundation
import AlertToast

struct InputSheet: PageView {
    @EnvironmentObject var repository:Repository
    let origin:String
    let placeHolder:String? = nil
    var completed: (String?) -> Void
    var body: some View {
        ZStack(alignment: .topTrailing){
            Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                .onTapGesture {
                    AppUtil.hideKeyboard()
                }
            VStack(spacing: Dimen.margin.thin){
                Form{
                    TextField(placeHolder ?? "input text", text: self.$title, axis: .vertical)
                        .keyboardType(.default)
                        .modifier(BoldTextStyle())
                        .focused(self.$isFieldFocused)
                    
                    FillButton(
                        icon: Asset.icon.edit,
                        text: String.app.confirm,
                        isActive: !self.title.isEmpty
                    ){_ in
                        
                        self.completed(self.title)
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(height: 190)
            }
            .padding(.top, Dimen.margin.regular)
            ImageButton(
                defaultImage: Asset.component.button.close
            ){_ in
                self.completed(nil)
            }
            .padding(.all, Dimen.margin.regular)
        }
        .padding(.bottom, Dimen.margin.medium)
        .modifier(MatchParent())
        .background(Color.brand.bg)
       
        .onAppear(){
            self.title = self.origin
            self.isFieldFocused = true
        }
        .onDisappear(){
            self.isFieldFocused = false
        }
    }
    @FocusState var isFieldFocused: Bool
    @State private var title:String = ""
        
}



