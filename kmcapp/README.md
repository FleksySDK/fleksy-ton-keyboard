# TON Blockchain Web Application

This project is a web application that interacts with the TON blockchain, featuring wallet connection capabilities and jetton (token) management functionality. It consists of a React frontend and Node.js backend.

## Project Structure

```
.
├── frontend/ # React frontend application
└── backend/ # Node.js backend server
```

## Features

- TON wallet connection using TonConnect
- Jetton (token) balance checking
- Jetton transfer functionality
- Native app communication bridge (iOS WebView integration)
- CloudFront deployment support

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- AWS CLI (for deployment)

## Frontend Setup

1. Navigate to the frontend directory:

```
bash
cd frontend
```

2. Install dependencies:

```
bash
npm install
```

3. Create a `.env` file with required environment variables following the `.env.example` file.

4. Start the development server:

```
npm start
```

The frontend will be available at `http://localhost:3000`

## Backend Setup

1. Navigate to the backend directory:

```
bash
cd backend
```

2. Install dependencies:

```
npm install
```

3. Create a `.env` file with required environment variables following the `.env.example` file.

4. Start the development server:

```
npm run dev
```

The backend will be available at `http://localhost:3001`

## API Endpoints

### GET /api/jettons-info/:address
Returns jetton balance and metadata for a given wallet address.

### POST /api/send-jettons
Transfers jettons to a specified address.

Request body:

```
json
{
    "receiverAddress": "TON_wallet_address",
    "payload": "keyboard data capture payload"
}
```

## Deployment

### Frontend Deployment

The project includes a deployment script for AWS S3 and CloudFront. To deploy:

1. Create a `.env.deploy` file in the frontend directory following the `.env.deploy.example` file.

2. Run the deployment script:

```
bash
./deploy.sh
```

## Development Notes

- The frontend uses Create React App and TonConnect for wallet integration
- The backend uses Express.js and the TON SDK for blockchain interactions
- The application includes native app communication bridges for iOS WebView integration

## Security Notes

- Never commit `.env` files to version control
- Protect your wallet seed phrase and API keys
- The backend includes CORS configuration for specified origins only

## References

- [TON Documentation](https://ton.org/docs)
- [TonConnect Documentation](https://github.com/ton-connect/sdk)
- [Create React App Documentation](https://create-react-app.dev/)