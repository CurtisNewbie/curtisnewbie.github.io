---
layout: post
title: "Fix JDK CA Certificates"
date: 2025-01-16 19:00:00 +0800
categories: Learning
---

Java internally maintain a list of CA certificates. These CA certificates are shipped with the JDK installed.

These CA certificates are usually stored at following locations:

- Recent JDK Versions: `$JAVA_HOME/lib/security/cacerts`
- Older JDK Versions:`$JAVA_HOME/jre/lib/security/cacerts`

For example, on MacOS:

```sh
bash$ file $JAVA_HOME/jre/lib/security/cacerts

/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home//jre/lib/security/cacerts: Java KeyStore
```

This file is in binary format, you cannot edit the file directly.

When your JDK version is outdated, the CA certificates that come with the JDK are also outdated. Your HTTP client code may fail to request a website with valid SSL certificate.

You may see exception stacktrace like the following:

```java
javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
	at sun.security.ssl.Alert.createSSLException(Alert.java:131)
	at sun.security.ssl.TransportContext.fatal(TransportContext.java:377)
	at sun.security.ssl.TransportContext.fatal(TransportContext.java:320)
	at sun.security.ssl.TransportContext.fatal(TransportContext.java:315)
	at sun.security.ssl.CertificateMessage$T13CertificateConsumer.checkServerCerts(CertificateMessage.java:1355)
	at sun.security.ssl.CertificateMessage$T13CertificateConsumer.onConsumeCertificate(CertificateMessage.java:1230)
	at sun.security.ssl.CertificateMessage$T13CertificateConsumer.consume(CertificateMessage.java:1173)
	at sun.security.ssl.SSLHandshake.consume(SSLHandshake.java:376)
	at sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:479)
	at sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:457)
	at sun.security.ssl.TransportContext.dispatch(TransportContext.java:200)
	at sun.security.ssl.SSLTransport.decode(SSLTransport.java:155)
	at sun.security.ssl.SSLSocketImpl.decode(SSLSocketImpl.java:1320)
	at sun.security.ssl.SSLSocketImpl.readHandshakeRecord(SSLSocketImpl.java:1233)
	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:417)
	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:389)
	at okhttp3.internal.connection.RealConnection.connectTls(RealConnection.java:336)
	at okhttp3.internal.connection.RealConnection.establishProtocol(RealConnection.java:300)
	at okhttp3.internal.connection.RealConnection.connect(RealConnection.java:185)
	at okhttp3.internal.connection.ExchangeFinder.findConnection(ExchangeFinder.java:224)
	at okhttp3.internal.connection.ExchangeFinder.findHealthyConnection(ExchangeFinder.java:108)
	at okhttp3.internal.connection.ExchangeFinder.find(ExchangeFinder.java:88)
	at okhttp3.internal.connection.Transmitter.newExchange(Transmitter.java:169)
	at okhttp3.internal.connection.ConnectInterceptor.intercept(ConnectInterceptor.java:41)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:142)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:117)
	at okhttp3.internal.cache.CacheInterceptor.intercept(CacheInterceptor.java:94)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:142)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:117)
	at okhttp3.internal.http.BridgeInterceptor.intercept(BridgeInterceptor.java:93)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:142)
	at okhttp3.internal.http.RetryAndFollowUpInterceptor.intercept(RetryAndFollowUpInterceptor.java:88)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:142)
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:117)
	at okhttp3.RealCall.getResponseWithInterceptorChain(RealCall.java:229)
	at okhttp3.RealCall.execute(RealCall.java:81)
    ...
```

You can also verify the SSL issue if the OS's CA certificates are also outdated, e.g., using cURL:

```sh
bash# curl https://**** -v

* Rebuilt URL to: https://***/
*   Trying ***.***.***.***...
* TCP_NODELAY set
* Connected to ***.***.*** (***.***.***) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
  CApath: none
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
* SSL certificate problem: unable to get local issuer certificate
* Closing connection 0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

You have three options to fix the CA certificates issue:

1. Fix CA Certificates of JDK (and OS)
2. Configure Java HTTP Client to trust all certificates
3. Upgrade JDK (only the minor version)

Second option is not recommended, and third option is preferable but sometimes not possible (in your company).

In my case, I (have to) choose to first option; fixing the CA certificates by importing certificate PEM to JDK's cacerts.

> Assume that we trust the website's existing certificates.

First, we open the website using Chrome, open the website's certificate details, and export the certificates. Notice that sometimes you not only need the top layer certificate, you also need the middle one, so you may end up exporting more than one `*.pem` certificate files.

We then fix OS's CA certificates by copying the content of these exported certificate files to OS's `*.crt` file. The location of the `*.crt` file really depends on which OS your are using.

E.g., in REHL, the OS's certificates may be located at: `/etc/pki/tls/certs/ca-bundle.crt`, if you are using Ubuntu or something else, it will be different, just google it.

Once we have copied the exported certificates content to this `*.crt` file, the cURL should work normally. It at least proves that the certificates that we just exported are correct.

For JDK (or say JRE), we use the built-in JDK tools `keytool` to import the certificates, the command looks like the following:

```sh
keytool -import -storepass changeit -noprompt -trustcacerts -alias my_exported_certificate_1 -file my_exported_1.crt -keystore $JAVA_HOME/jre/lib/security/cacerts

keytool -import -storepass changeit -noprompt -trustcacerts -alias my_exported_certificate_2 -file my_exported_2.crt -keystore $JAVA_HOME/jre/lib/security/cacerts
```

Notice that JDK's cacerts by default use password `changeit`, so we just pass in the password using CLI arg `-storepass` without the prompt.

Since we may need to import mulitple certificates, you will need to run the `keytool` commands multiple times for each of these certificates, because `keytool` only supports importing one certificate at a time.

Restart the Java application to apply the changes, then you are good to go.

If it doesn't work, you may have a look at the content of the cacert file. Again, you can just use the `keytool` command as follows:

```sh
keytool -list -v -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit | less
```

Have a look at the total number of entries to check if the certificates are indeeded imported. You can also check the expiry time and make sure the certificates are still valid (e.g., `valid from *** until ***`).