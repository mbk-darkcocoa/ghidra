# Ghidra on a Google Cloud VM with SELinux and Browser Access

This guide documents a supported deployment approach for running Ghidra on a Google Cloud VM when:

* SELinux must remain enforcing
* browser access is required from Chromium or another modern browser
* administrative access must be restricted behind a reverse proxy

## Recommended runtime model

Use one of these two runtime patterns:

1. **Native GUI on the VM plus a browser remoting layer** for full interactive desktop use in Chromium.
2. **Docker `headless` or `pyghidra` mode** for scripted analysis, CI, or batch processing.

Do **not** expose raw X11 to the network.

Do **not** use `MODE=ghidra-server` on a Linux VM where SELinux must remain enforcing. The existing
server documentation notes that Ghidra Server may not start properly unless SELinux is disabled; see
`Ghidra/RuntimeScripts/server/svrREADME.md`.

## VM baseline

For a SELinux-enforcing deployment, use a Linux distribution with first-class SELinux support.

Recommended baseline:

* Google Compute Engine VM
* Rocky Linux 9 or another SELinux-enabled enterprise Linux distribution
* Persistent disk sized for the repository checkout, Gradle caches, dependencies, and build output
* Firewall rules limited to:
  * SSH for administration
  * a single HTTPS entry point for browser access

## Build prerequisites

The repository build requires:

* JDK 25
* Gradle 9.1 or newer, or the Gradle wrapper when available
* Python 3.9 through 3.14 with bundled `pip`
* GCC or Clang and `make`

## Build Ghidra from this repository

On the VM, build from the source checkout:

```bash
cd <ghidra-source-root>
gradle -I gradle/support/fetchDependencies.gradle
gradle buildGhidra
```

The compressed development build is written to:

```text
build/dist/
```

If you want an uncompressed platform-local distribution instead, use:

```bash
cd <ghidra-source-root>
gradle assembleAll
```

## Full browser-based GUI access

For a full desktop experience in Chromium, run the built Ghidra distribution natively on the VM and
place a browser remoting layer in front of that desktop session. This avoids raw X11 exposure and
works better with SELinux than trying to force the existing Docker GUI mode into a browser-first
deployment.

Recommended characteristics for the remoting layer:

* binds only to `127.0.0.1`
* serves an HTTPS-capable web UI
* supports WebSocket proxying
* does not expose its administrative interface publicly

Place a reverse proxy in front of that remoting layer and make the proxy the only internet-facing
service.

## Reverse proxy pattern

Terminate TLS at the reverse proxy and forward only to loopback services on the VM.

Example `nginx` structure:

```nginx
server {
    listen 443 ssl http2;
    server_name ghidra.example.com;

    ssl_certificate     /etc/pki/tls/certs/ghidra.crt;
    ssl_certificate_key /etc/pki/tls/private/ghidra.key;

    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/ghidra-users.htpasswd;

    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }

    location /admin/ {
        auth_basic "Chiefadmin";
        auth_basic_user_file /etc/nginx/ghidra-admin.htpasswd;
        proxy_pass http://127.0.0.1:8080/admin/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

Keep the browser remoting service bound to loopback only. Restrict administrative routes to the
intended admin credential set or identity provider group.

## SELinux guidance

Keep SELinux in enforcing mode:

```bash
getenforce
```

For reverse proxies that connect to local upstream services, enable the standard SELinux boolean:

```bash
sudo setsebool -P httpd_can_network_connect 1
```

If you store deployment data under a custom path, label it intentionally. Example:

```bash
sudo semanage fcontext -a -t container_file_t '/srv/ghidra(/.*)?'
sudo restorecon -Rv /srv/ghidra
```

When bind-mounting host directories into containers on a SELinux host, use labeled mounts so the
container can access them without disabling SELinux:

```bash
-v /srv/ghidra/projects:/home/ghidra/projects:Z
```

Only add the minimum extra SELinux policy required for the specific browser remoting software you
choose.

## Docker for headless and scripted workflows

The repository's Docker support is the preferred runtime for headless and scripted use on the VM.

To build the Docker image from a built Ghidra release:

1. Build Ghidra from source as described above.
2. Extract the archive from `build/dist/`.
3. Run `docker/build-docker-image.sh` from the extracted release root.

Example:

```bash
cd /tmp
unzip <ghidra-source-root>/build/dist/ghidra_*.zip
cd /tmp/ghidra_*
./docker/build-docker-image.sh
```

Example headless invocation on a SELinux host:

```bash
docker run \
    --env MODE=headless \
    --rm \
    --volume /srv/ghidra/projects:/home/ghidra/projects:Z \
    --volume /srv/ghidra/input:/home/ghidra/input:Z \
    ghidra/ghidra:<version> \
    /home/ghidra/projects project -import /home/ghidra/input/sample.bin
```

Example PyGhidra invocation on a SELinux host:

```bash
docker run \
    --env MODE=pyghidra \
    --rm \
    --volume /srv/ghidra/projects:/home/ghidra/projects:Z \
    ghidra/ghidra:<version> \
    -c "import pyghidra; print(pyghidra.__file__)"
```

## Hardening checklist

* Keep inbound firewall rules limited to SSH and the single HTTPS proxy entrypoint.
* Do not expose internal ports used by the browser remoting layer, Docker containers, X11, or build
  tooling.
* Store TLS keys with restrictive filesystem permissions.
* Keep Ghidra, the JDK, Python, and the browser remoting stack patched.
* Log authentication and proxy access events.
* Audit privileged administrative actions on the VM.

## Validation checklist

Before declaring the deployment ready:

1. Confirm the repository build succeeds on the VM.
2. Confirm SELinux remains `Enforcing`.
3. Confirm the browser entrypoint works in Chromium.
4. Confirm only the reverse proxy is reachable from the network.
5. Confirm non-admin users cannot reach admin-only routes.
6. Confirm Docker bind mounts use SELinux labeling where required.
