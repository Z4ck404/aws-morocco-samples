## Setting Up a Client VPN Connection

### Certificate Setup

1- Initialize PKI Structure

```bash
./easyrsa init-pki
```

2- Create Certificate Authority

```bash
./easyrsa build-ca nopass
```
3- Generate Server Certificate

```bash
./easyrsa build-server-full server.vpn.awsmorocco nopass
```

4- Generate Client Certificate
```bash
./easyrsa build-client-full vpn.zakaria.elbazi nopass
```

5- Import the created Server certificates to ACM

```bash
aws acm import-certificate \
    --certificate fileb://pki/issued/server.vpn.awsmorocco.crt \
    --private-key fileb://pki/private/server.vpn.awsmorocco.key \
    --certificate-chain fileb://pki/ca.crt \
    --region us-east-1
```

6- Import the created Client certificates to ACM

```bash
aws acm import-certificate \
    --certificate fileb://pki/issued/vpn.zakaria.elbazi.crt \
    --private-key fileb://pki/private/vpn.zakaria.elbazi.key \
    --certificate-chain fileb://pki/ca.crt \
    --region us-east-1
```