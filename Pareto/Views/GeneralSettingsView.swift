//
//  GeneralSettingsView.swift
//  GeneralSettingsView
//
//  Created by Janez Troha on 10/09/2021.
//

import Defaults
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject private var atLogin = LaunchAtLogin.observable
    @Default(.betaChannel) var betaChannel
    @Default(.showBeta) var showBeta
    @Default(.setappEmail) var appEmail

    var body: some View {
        Form {
            Section(
                footer: Text("To enable continuous monitoring and reporting.").font(.footnote)) {
                    VStack(alignment: .leading) {
                        Toggle("Automatically launch on system startup", isOn: $atLogin.isEnabled)
                    }
                }
            #if SETAPP_ENABLED
                let setappEmail = Binding<Bool>(
                    get: {
                        SCGetLastUserEmailSharingResponse() == .askLater || appEmail
                    },
                    set: {
                        print($0)
                        SCAskUserToShareEmail { (res: SCUserEmailSharingResponse) in
                            if res != .askLater  {
                                appEmail = true
                            }
                            
                        }
                    }
                )
                Section(
                    footer: Text("Receive occasional personalized email notifications ").font(.footnote)) {
                        VStack(alignment: .leading) {
                            Toggle("Subscribe me to a newsletter", isOn: setappEmail).disabled(appEmail)
                        }
                    }
            #endif
            if showBeta {
                Section(
                    footer: Text("Latest features but potentially bugs to report.").font(.footnote)) {
                        VStack(alignment: .leading) {
                            Toggle("Update app to pre-release builds", isOn: $betaChannel)
                        }
                    }

                #if DEBUG
                    HStack {
                        Button("Reset Settings") {
                            NSApp.sendAction(#selector(AppDelegate.resetSettingsClick), to: nil, from: nil)
                        }
                        Button("Show Welcome") {
                            NSApp.sendAction(#selector(AppDelegate.showWelcome), to: nil, from: nil)
                        }
                        Button("Update Flags") {
                            AppInfo.Flags.update()
                        }
                    }
                #endif
            }
        }

        .frame(width: 350, height: 100).padding(5)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
