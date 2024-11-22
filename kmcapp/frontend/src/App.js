import React, { useEffect, useState } from 'react';
import { TonConnectButton, useTonWallet, TonConnectUIProvider, toUserFriendlyAddress } from '@tonconnect/ui-react';

import './App.css';

const manifestUrl = `${window.location.origin}/tonconnect-manifest.json`;

function AppContent() {
    const wallet = useTonWallet();
    const [prevWalletConnected, setPrevWalletConnected] = useState(false);

    useEffect(() => {
        const isCurrentlyConnected = !!wallet;
        if (isCurrentlyConnected !== prevWalletConnected) {
            if (isCurrentlyConnected) {
                sendMessageToNative('onConnectWallet', true, toUserFriendlyAddress(wallet.account.address));
            } else {
                sendMessageToNative('onDisconnectWallet', true, 'Wallet disconnected');
            }
            setPrevWalletConnected(isCurrentlyConnected);
        }
    }, [wallet, prevWalletConnected]);

    useEffect(() => {
        window.receiveMessageFromNative = (type, payload) => {
        };
    });

    const sendMessageToNative = (type, success, message) => {
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
            const payload = {
                type: type,
                success: success,
                message: message
            };
            window.webkit.messageHandlers.nativeApp.postMessage(JSON.stringify(payload));
        }
    };

    return (
        <div className="app">
            <header className="app-header">
                <div className="header-container">
                    <div className="connect-button-wrapper">
                        <TonConnectButton />
                    </div>
                </div>
            </header>
        </div>
    );
}

function App() {
    return (
        <TonConnectUIProvider manifestUrl={manifestUrl} actionsConfiguration={{returnStrategy: 'kmc://reload'}}>
            <AppContent />
        </TonConnectUIProvider>
    );
}

export default App; 