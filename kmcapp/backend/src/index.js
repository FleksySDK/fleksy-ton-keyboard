const express = require('express');
const cors = require('cors');
const { TonClient, JettonWallet, JettonMaster, internal } = require('ton');
const { mnemonicToWalletKey } = require('ton-crypto');
const { WalletContractV4, Dictionary, Slice, Cell } = require('ton');
const { beginCell, Address, toNano} = require('ton');

require('dotenv').config();

const app = express();

const corsOptions = {
    origin: [
        'http://localhost:3000',
        'http://192.168.1.67:3000',
        'https://d4rh1z6vnsnbq.cloudfront.net'
    ],
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type']
};

app.use(cors(corsOptions));
app.use(express.json());

// Global wallet variables
let globalWallet;
let globalKey;

// Initialize TON client
const client = new TonClient({
    endpoint: 'https://toncenter.com/api/v2/jsonRPC',
    apiKey: process.env.TON_API_KEY
});

async function initializeWallet() {
    const mnemonic = process.env.WALLET_SEED_PHRASE.split(' ');
    const key = await mnemonicToWalletKey(mnemonic);
    const wallet = WalletContractV4.create({
        publicKey: key.publicKey,
        workchain: 0
    });
    
    // Get wallet address
    const walletAddress = wallet.address.toString();
    console.log('Wallet initialized with address:', walletAddress);

    let balance = await client.getBalance(wallet.address);
    console.log('Wallet balance:', balance);
    
    return { wallet, key };
}

// Initialize wallet before starting server
async function startServer() {
    try {
        const walletData = await initializeWallet();
        globalWallet = walletData.wallet;
        globalKey = walletData.key;
        
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    } catch (error) {
        console.error('Failed to initialize wallet:', error);
        process.exit(1);
    }
}

app.post('/api/send-jettons', async (req, res) => {
    try {
        const { receiverAddress, payload } = req.body;
        
        const amount = 0.01;
        const parsedAmount = BigInt(Math.floor(parseFloat(amount) * 1e9));
        if (parsedAmount <= 0) {
            return res.status(400).json({ success: false, error: 'Invalid amount' });
        }

        // Create transfer body
        const transferBody = beginCell()
            .storeUint(0xf8a7ea5, 32) // transfer op code
            .storeUint(1, 64) // query id
            .storeCoins(parsedAmount) // amount
            .storeAddress(Address.parse(receiverAddress)) // destination address
            .storeAddress(globalWallet.address) // response destination
            .storeBit(false)
            .storeCoins(toNano('0.01')) // forward amount
            .storeBit(false) // forward payload
            .endCell();

        // Create and send the transfer transaction
        const contract = client.open(globalWallet);
        const seqno = await contract.getSeqno();
        
        const transfer = await contract.createTransfer({
            seqno,
            secretKey: globalKey.secretKey,
            messages: [internal({                
                to: process.env.JETTON_WALLET_ADDRESS,
                value: toNano('0.05'),
                body: transferBody
            })]
          });

        await contract.send(transfer);

        // Add verification
        const success = await verifyTransaction(seqno, contract);
        
        if (!success) {
            throw new Error('Transaction verification failed');
        }

        console.log('Jetton transfer completed and verified successfully');
        
        res.json({ 
            success: true, 
            transaction: transfer,
            verified: true 
        });        
    } catch (error) {
        console.error('Transaction error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

async function verifyTransaction(seqno, contract, maxAttempts = 10) {
    for (let attempt = 0; attempt < maxAttempts; attempt++) {
        await new Promise(resolve => setTimeout(resolve, 3000)); // Wait 3 seconds between checks
        
        try {
            const currentSeqno = await contract.getSeqno();
            
            // If seqno has increased, the transaction was processed
            if (currentSeqno > seqno) {
                return true;
            }
            
            console.log(`Verification attempt ${attempt + 1}/${maxAttempts}...`);
        } catch (error) {
            console.error('Error checking transaction:', error);
        }
    }
    
    return false;
}

function loadSnakeString(slice) {
    let result = slice.loadStringTail();
    return result.replace(/^\0/, '');  // Remove the null character from the start of the string
}

function parseJettonMetadata(content) {
    const StringValue = {
        parse: (cell) => {
            return loadSnakeString(cell);
        }
    };
    let slice = content.beginParse();
    
    // First byte indicates the metadata type
    let prefix = slice.loadUint(8);
    
    let metadata = {};
    
    // If it's onchain format (0x00)
    if (prefix === 0) {
        // Create dictionary from the remaining data
        let dict = Dictionary.loadDirect(
            Dictionary.Keys.Buffer(32),
            StringValue,
            slice.loadRef()
        );
        
        // Standard jetton metadata keys
        const keys = ['image', 'name', 'symbol', 'description'];
        
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i];
            metadata[key] = dict.values()[i];
        }
    }
    
    return metadata;
}

app.get('/api/jettons-info/:address', async (req, res) => {
    try {
        const { address } = req.params;
        
        const jettonMaster = client.open(
            JettonMaster.create(Address.parse(process.env.JETTON_CONTRACT_ADDRESS))
        );

        const userJettonAddress = await jettonMaster.getWalletAddress(
            Address.parse(address)
        );

        const jettonWallet = client.open(
            JettonWallet.create(userJettonAddress)
        );

        const [balance, jettonData] = await Promise.all([
            jettonWallet.getBalance(),
            jettonMaster.getJettonData()
        ]);

        const wholeBalance = Number(balance) / 1e9;

        metadata = parseJettonMetadata(jettonData.content);        

        res.json({
            success: true,
            data: {
                balance: wholeBalance,
                metadata: metadata,
                jettonWalletAddress: userJettonAddress.toString()
            }
        });

    } catch (error) {
        console.error('Error fetching jetton balance:', error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

const PORT = process.env.PORT || 3001;
startServer(); 