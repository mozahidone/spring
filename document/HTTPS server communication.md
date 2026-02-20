# Local Spring Boot -> Internal Server (HTTPS) Notes

This repo documents a workaround + the proper fix we used when a Spring Boot app running on **localhost** needed to call an internal HTTPS server (example: `https://10.0.1.30/...`) and failed TLS verification.

## When you’d need this
Typical errors look like:
- `javax.net.ssl.SSLHandshakeException: PKIX path building failed`
- `sun.security.validator.ValidatorException: PKIX path building failed`

That means Java doesn’t trust the server certificate (or the issuing CA), or the certificate doesn’t match the hostname/IP.

---

## Option A (quick workaround / NOT recommended for production)
### Disable hostname verification in code
Add the following in the Java code path that runs before your HTTPS call(s) (for example in app startup, or right before creating the connection):

```java
import javax.net.ssl.HttpsURLConnection;

// WARNING: Disables hostname verification for all HTTPS connections in this JVM.
HttpsURLConnection.setDefaultHostnameVerifier((hostname, session) -> true);
```

### Security warning
This effectively tells the JVM: “accept any certificate for any hostname”. It can expose you to MITM attacks and should only be used temporarily for debugging in trusted networks.

---

## Option B (recommended): trust the server certificate (or CA)
### 1) Export the server certificate from Chrome
1. Open Chrome and browse to the server URL (example: `https://10.0.1.30`).
2. Click the padlock icon → **Connection is secure** → **Certificate is valid**.
3. In the certificate viewer, go to **Details** → **Export...**.
4. Save it locally (commonly as `.cer` or `.crt`).

> Tip: If there’s a certificate chain, it’s often better to export/import the **issuing CA** certificate rather than the leaf certificate.

### 2) Import the certificate into the JDK truststore (`cacerts`)
Java uses a truststore to decide which certificates to trust. The default one is typically:
- `<YourJDKPath>\lib\security\cacerts`

Use `keytool` to import your exported certificate.

#### PowerShell command
Replace:
- `<YourJDKPath>` with the JDK actually used to run the Spring Boot app (IDE/Gradle/Maven/service).
- `<CERTPATH>` with the path to the exported certificate.

```powershell
keytool -import -alias ntt -keystore "<YourJDKPath>\lib\security\cacerts" --file "<CERTPATH>"
```

When prompted for the keystore password:
- Default password: `changeit`

If asked to trust the certificate, answer `yes`.

### 3) Restart and retest
- Restart your app (and sometimes your IDE) so it picks up the updated truststore.
- Retry the HTTPS call.

---

## Troubleshooting
### Which JDK is my app using?
Common gotcha: you import into one JDK, but the app runs on another.

Ways to confirm:
- Print: `System.getProperty("java.home")`
- Check IDE project SDK / Gradle JVM / Maven JVM.

### Alias already exists
If you already imported once, you may see an alias conflict.

List entries:
```powershell
keytool -list -keystore "<YourJDKPath>\lib\security\cacerts" -alias ntt
```

Delete and re-import:
```powershell
keytool -delete -alias ntt -keystore "<YourJDKPath>\lib\security\cacerts"
keytool -import -alias ntt -keystore "<YourJDKPath>\lib\security\cacerts" --file "<CERTPATH>"
```

### Certificate still fails for IP address
If the cert was issued for a DNS name but you’re calling via IP (e.g., `10.0.1.30`), hostname verification can still fail.

Best fixes:
- Use the DNS name that matches the certificate.
- Re-issue the server certificate with a **Subject Alternative Name (SAN)** that includes the IP.

---

## Safer alternative (app-specific truststore)
Instead of modifying global `cacerts`, you can create an app-specific truststore (JKS/PKCS12) and point Spring Boot to it (property names vary depending on whether it’s server-side or client-side TLS).

If you want, we can add a `truststore.jks` workflow + Spring config snippet for this project once we know whether you’re using `RestTemplate`, `WebClient`, Apache HttpClient, or raw `HttpsURLConnection`.
