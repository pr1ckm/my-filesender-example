<?php

$config['site_name'] = 'FileSender v3.0 Local';
$config['site_url'] = 'http://localhost:8080/';

$config['admin'] = 'admin@example.com';
$config['admin_email'] = 'admin@example.com';
$config['email_reply_to'] = 'admin@example.com';
$config['salt'] = 'c83b2a10e9f8d7c6b5a43210fedcba9876543210abcdef';

// PostgreSQL-Datenbank
$config['db_type'] = 'pgsql';
$config['db_host'] = 'db';
$config['db_port'] = 5432;
$config['db_database'] = 'filesender';
$config['db_username'] = 'filesender';
$config['db_password'] = 'filesenderpass';

// Speicher- & Log-Pfade
$config['storage_type'] = 'filesystem';
$config['storage_filesystem_path'] = '/opt/filesender/files';
$config['log_facility'] = 'file';
$config['log_file'] = '/opt/filesender/log/filesender.log';

$config['force_ssl'] = false;

// Authentifizierung (Fake-Modus)
$config['auth_sp_type'] = 'fake';
$config['auth_sp_fake_authenticated'] = true;
$config['auth_sp_fake_uid'] = 'admin';
$config['auth_sp_fake_email'] = 'admin@example.com';
$config['auth_sp_fake_name'] = 'Admin User';
