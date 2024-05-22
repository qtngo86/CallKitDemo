//
//  ProviderDelegate.swift
//  CallKitDemo
//
//  Created by Quang Tuan NGO on 2024-05-21.
//

import AVFoundation
import CallKit

class ProviderDelegate: NSObject {
    private let callManager: CallManager
    private let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: ProviderDelegate.providerConfiguration)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Hotline")
        
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        return providerConfiguration
    }()
    
    func reportIncomingCall(
        uuid: UUID,
        handle: String,
        hasVideo: Bool = false,
        completion: ((Error?) -> Void)?
    ) {
        print("Report incoming call")
        let update = CXCallUpdate()
        update.localizedCallerName = "Test Username"
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let updateCallerName = CXCallUpdate()
            updateCallerName.localizedCallerName = "Test Username Updated"
            self?.provider.reportCall(with: uuid, updated: updateCallerName)
        }
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let call = Call(uuid: uuid, handle: handle)
                self.callManager.add(call: call)
            }
            
            print("Report incoming call with error = \(error.debugDescription)")
            completion?(error)
        }
    }
}

// MARK: - CXProviderDelegate
extension ProviderDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        stopAudio()
        
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        configureAudioSession()
        
        call.answer()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        startAudio()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        stopAudio()
        
        call.end()
        
        action.fulfill()
        
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        
        if call.state == .held {
            stopAudio()
        } else {
            startAudio()
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.callUUID, outgoing: true,
                        handle: action.handle.value)
        
        configureAudioSession()
        
        call.connectedStateChanged = { [weak self, weak call] in
            guard
                let self = self,
                let call = call
            else {
                return
            }
            
            if call.connectedState == .pending {
                self.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if call.connectedState == .complete {
                self.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self, weak call] success in
            guard
                let self = self,
                let call = call
            else {
                return
            }
            
            if success {
                action.fulfill()
                self.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
}

