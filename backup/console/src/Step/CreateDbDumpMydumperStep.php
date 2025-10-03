<?php

namespace App\Step;

/**
 * Create dump.
 */
class CreateDbDumpMydumperStep extends StepBase {

  const SITE_ROOT = '/var/www/html';
  const DBHOST = 'localhost';
  const DBUSER = 'drupal';
  const DBPASS = 'drupal';
  const DBNAME = 'drupal';
  const DBDUMP_DIR = '.db';
  const THREADS = 8;
  const CHUNK_SIZE = 256;

  /**
   * Run.
   */
  public function run() : bool {
    $dbhost = $_ENV['DBHOST'] ?: self::DBHOST;
    $dbuser = $_ENV['DBUSER'] ?: self::DBUSER;
    $dbpass = $_ENV['DBPASS'] ?: self::DBPASS;
    $dbname = $_ENV['DBNAME'] ?: self::DBNAME;
    $dbdump_dir = $_ENV['DBDUMP_DIR'] ?: implode('/', [self::SITE_ROOT, self::DBDUMP_DIR]);
    $threads = $_ENV['MYDUMPER_THREADS'] ?: self::THREADS;
    $chunk_filesize = $_ENV['MYDUMPER_CHUNK_SIZE'] ?: self::CHUNK_SIZE;

    $result = $this->command->runProcess('mkdir -p ' . $dbdump_dir);

    $cmd = sprintf(
      'mydumper \
--host="%s" \
--user="%s" \
--password="%s" \
--database="%s" \
--outputdir="%s" \
--threads="%d" \
--chunk-filesize="%d" \
--no-locks \
--success-on-1146 \
--verbose=2 \
--logfile="%s/mydumper.log"',
      $dbhost, $dbuser, $dbpass, $dbname, $dbdump_dir, $threads, $chunk_filesize, $dbdump_dir
    );
    $result = $this->command->runProcess($cmd);

    $this->command->logExecute(
      $result['success'] ?? FALSE,
      'Mydumper db-dump',
      $result['error'] ?? 'Failed to create MySQL db-dump'
    );

    return $result['success'] ?? FALSE;
  }

}
