# FileSender v3.0 – Local Docker Development Environment

Eine schlüsselfertige, containerbasierte Entwicklungsumgebung für **FileSender v3.0** auf Basis von PHP 8.2 (Apache) und PostgreSQL 15.

Dieses Repository ermöglicht es, eine lokale Instanz der Open-Source-Dateiübertragungsanwendung FileSender schnell und unkompliziert mittels Docker Compose bereitzustellen. Es beinhaltet eine automatisierte Datenbank-Initialisierung, ein vorbereitetes Test-Authentifizierungsmodul und persistente Datenspeicher.

---

## Inhaltsverzeichnis

- [Übersicht & Architektur](#-übersicht--architektur)
- [Projektstruktur](#-projektstruktur)
- [Voraussetzungen](#-voraussetzungen)
- [Schnellstart](#-schnellstart)
- [Konfiguration](#-konfiguration)
- [Dienste & Ports](#-dienste--ports)
- [Nützliche Befehle](#-nützliche-befehle)

---

## Übersicht & Architektur

Das Setup besteht aus zwei Hauptcontainer-Diensten:

1. **`filesender-app` (Webserver / Anwendung)**
   - Basiert auf `php:8.2-apache` und klont den aktuellen `master3`-Branch von FileSender.
   - Enthält alle erforderlichen PHP-Erweiterungen (`pdo_pgsql`, `pgsql`, `gd`, `zip`, `intl`, `bcmath` etc.) sowie Composer.
   - Nutzt ein benutzerdefiniertes `entrypoint.sh`-Skript, das beim Start auf die Erreichbarkeit der Datenbank wartet und ausstehende Schema-Migrationen automatisch ausführt.
   - Setzt das Apache-DocumentRoot korrekt auf `/opt/filesender/www`.

2. **`filesender-db` (Datenbank)**
   - Basiert auf `postgres:15-alpine`.
   - Führt automatische Healthchecks aus (`pg_isready`), um sicherzustellen, dass die Anwendung erst nach erfolgreicher Datenbankbereitschaft startet.

---

## Projektstruktur

```text
.
├── docker-compose.yml   # Multi-Container-Orchestrierung & Volume-Definitionen
├── Dockerfile           # Build-Anweisungen für das FileSender v3.0 Apache/PHP-Image
├── entrypoint.sh        # Container-Entrypoint (DB-Wait-Check & Schema-Migration)
└── config/
    └── config.php       # FileSender-Konfigurationsdatei (DB-Credentials, Paths, Fake-Auth)
```

---

## Voraussetzungen

Stelle sicher, dass folgende Software auf deinem System installiert ist:

- [Docker Engine](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

---

## Schnellstart

1. **Repository klonen:**
   ```bash
   git clone https://github.com/dein-username/filesender-docker.git
   cd filesender-docker
   ```

2. **Container starten:**
   ```bash
   docker compose up -d
   ```

3. **Anwendung im Browser öffnen:**
   Navigiere zu [http://localhost:8080](http://localhost:8080).

   > **Hinweis zur Authentifizierung:**
   > In `config/config.php` ist standardmäßig der Fake-Authentifizierungsmodus aktiviert (`auth_sp_type = 'fake'`). Du wirst automatisch als **Admin User** (`admin@example.com`) eingeloggt.

---

## Konfiguration

Die zentrale Konfiguration befindet sich in `config/config.php`.

### Wichtige Einstellungen:

- **Basis-URL & Name:**
  ```php
  $config['site_name'] = 'FileSender v3.0 Local';
  $config['site_url'] = 'http://localhost:8080/';
  ```

- **Datenbankverbindung (PostgreSQL):**
  ```php
  $config['db_type'] = 'pgsql';
  $config['db_host'] = 'db';
  $config['db_database'] = 'filesender';
  $config['db_username'] = 'filesender';
  $config['db_password'] = 'filesenderpass';
  ```

- **Speicher- & Log-Pfade:**
  ```php
  $config['storage_type'] = 'filesystem';
  $config['storage_filesystem_path'] = '/opt/filesender/files';
  $config['log_file'] = '/opt/filesender/log/filesender.log';
  ```

---

## Dienste & Ports

| Dienst | Container-Name | Port (Host:Container) | Beschreibung |
| :--- | :--- | :--- | :--- |
| **filesender** | `filesender-app` | `8080:80` | FileSender v3.0 Web-Interface |
| **db** | `filesender-db` | *Keiner (intern 5432)* | PostgreSQL 15 Datenbank |

### Persistente Volumes

- `pgdata`: Speichert die PostgreSQL-Datenbankdatenbank-Dateien.
- `files_data`: Speichert hochgeladene Dateien (`/opt/filesender/files`).
- `log_data`: Speichert Anwendungs-Logs (`/opt/filesender/log`).

---

## Nützliche Befehle

- **Logs in Echtzeit anzeigen:**
  ```bash
  docker compose logs -f
  ```

- **Logs nur für die FileSender-Anwendung:**
  ```bash
  docker compose logs -f filesender
  ```

- **Status der Container prüfen:**
  ```bash
  docker compose ps
  ```

- **In die Container-Shell einloggen:**
  ```bash
  docker compose exec filesender bash
  ```

- **Container stoppen und Volumes behalten:**
  ```bash
  docker compose down
  ```

- **Container stoppen und alle Daten/Volumes löschen:**
  ```bash
  docker compose down -v
  ```

- **Image neu bauen (z. B. nach Änderungen am Dockerfile):**
  ```bash
  docker compose up -d --build
  ```
