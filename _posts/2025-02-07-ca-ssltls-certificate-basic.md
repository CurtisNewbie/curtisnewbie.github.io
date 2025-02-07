---
layout: post
title: "CA, SSL/TLS Certificate Basic"
date: 2025-02-07 09:00:00 +0800
categories: Learning
---

## 1. CA and SSL/TLS Certificates

CA stands for Certificate Authority. CA certificates usually refer to the digital certificates issued by CAs, the trusted entities, sometime we call these certificates "the root certificates".

The SSL/TLS certificates are mainly used to help us verify the identities of the servers that we are connecting to, but the certificates do not contain any IP addresses, only the domain name and other related information (e.g., about the organization and so on).

DNS server resolves the IPs for the provided domain name, and the resolution happens before SSL/TLS connection. If the DNS server is hijacked, then SSL/TLS doesn't protect the clients, since the hijacked DNS servers may have already redirected the client to a fake server before the SSL/TLS handshake.

Given that DNS server is not hijacked, the SSL/TLS certificates installed on the servers (the website) can be used to verify the identity of the domain name. Since the DNS server provides valid IPs for the domain name, we can be sure that we are connecting to the trusted servers for the website. In other words, SSL/TLS certificates protect the domain name(s).

## 2. How CA Certificates Help?

Recall that CAs are the trusted entities, and CA certificates are signed and issued by CAs using private key. With RSA, private key is used to generate digital signature (i.e., signing stuff) and public key is used to verify the digital signature.

Almost all OSs or some programming language runtimes (e.g., Java bundles the root CAs certificates in its runtime) maintain a list of trusted, root CAs certificates.

When clients connect to servers, during the SSL/TLS handshake, the servers send the installed SSL/TLS certificates to the clients. Clients then examine the certificate and identify the CA that issued it.

Since clients have a list of trusted CA certificates (e.g., from the OS), clients can use the public key in CA certificates to verify the certificates provided by the server, which is essentially using the public key to verify the digital signature on it. If the digital signature is valid and the certificate has not yet expired, then the certificate is trustworthy.

So, you may have wondered, if the OS or the programming language runtime are really outdated, they may not contain all the CA certificates. In which case, they may fail to verify the SSL/TLS certificates provided by the server even though they are valid.

## 3. Chain of Certificates

Chain of certificates is used to reduce the number of root CAs, it just simply means that there are multiple certificates in the chain, and each certificate is issued by the one before it, thus it's called a chain, not a list.

The ones in the middle of the chain is called intermediate certificate. These certificates are usually issued by entities that also issue SSL/TLS certificates. Intermediate certificates are just like normal SSL/TLS certificates, they are also verified by another certificate that issued them. The entities that issue intermediate certificates are called Intermediate CAs or Sub CAs.

When a website's certificate is issued by a intermediate CA not directly from a root CA, the website should install the chain of certificates on its servers such that when a client undertake SSL/TLS handshake with the server, the server replies the whole chain to the client (not just the one its domain name), and then the client can verify each certificate on the chain until the root CAs that the client alreay knew.

Below is a simple visualization for the logic behind.

```
[Root CA Certificates]
            ^
            |
            | verified using root CA certificate's public key
            |
            |
[Intermediate Certificates]
            ^
            |
            | verified using intermediate CA certificate's public key
            |
            |
[Domain Certificate - The Website]
```

So, what might go wrong when using chain of certificates? If the server's domain certificate is not signed by any known root CA certificate, and the intermediate certificates on the chain are not provided to the client, then the client will simply not be able to verify the domain certificate, it doesn't even know which root CA certificate this chain roots from.

A classic issue with intermediate certificates is that the web server misconfigures the chain of certificate, wherein the intermediate certificates are not provided to the clients, the client is unable to valid the domain certificate. The solution to this problem is either letting the client install the intermediate certificates or fix the certificate chain configuration.

The post ["2025-01-16 Fix JDK CA Certificates"](/learning/2025/01/16/fix-jdk-ca-certificates) is an example on installing the certificates on the client side, which is the last resort for fixing the SSL/TLS certificate problems.

## 4. Commands for Certificates

### View Certificate Details

Use following command to read the certificate file's content.

```sh
openssl x509 -text -in "***.crt"
```

### View Certificate Signature

Use following command to read certificate signature in sha256 / sha1 format, the command above also displays the signature, though they look slightly different.

```sh
openssl x509 -noout -fingerprint -sha256 -in "***.crt";
openssl x509 -noout -fingerprint -sha1 -in "***.crt";
```

### Fetch Chain of Certificates

Credit: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux

```sh
function root_cert() {
    openssl s_client -showcerts -verify 10 -connect $1:443 > /dev/null
}

function scrape_all_cert() {
    openssl s_client -showcerts -verify 10 -connect $1:443 < /dev/null |
    awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}'
    i=0
    echo ""
    for cert in *.pem; do
            newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').pem
            echo "- ${i} /tmp/${newname}"
            mv "$cert" "/tmp/${newname}"
            i=$((i+1))
    done
}
```

## 5. More

- https://stackoverflow.com/questions/40061263/what-is-ca-certificate-and-why-do-we-need-it
- https://www.cloudflare.com/learning/ssl/how-does-ssl-work/
- https://www.keyfactor.com/blog/what-is-a-certificate-signing-request-csr/
