<?php

namespace App\Step;

/**
 * Restore dump.
 */
class RestoreDbDumpMyloaderStep extends StepBase {

  const SITE_ROOT = '/var/www/html';
  const DBDUMP_DIR = '.db';
  const DBUSER = 'drupal';
  const DBPASS = 'drupal';
  const DBNAME = 'drupal';
  const THREADS = 8;
  const QUERIES_PER_TRANSACTION = 500;

  /**
   * Run.
   */
  public function run() : bool {
    $dbhost = $_ENV['DBHOST'] ?: self::DBHOST;
    $dbuser = $_ENV['DBUSER'] ?? self::DBUSER;
    $dbpass = $_ENV['DBPASS'] ?? self::DBPASS;
    $dbname = $_ENV['DBNAME'] ?? self::DBNAME;
    $dbdump_dir = $_ENV['DBDUMP_DIR'] ?: implode('/', [self::SITE_ROOT, self::DBDUMP_DIR]);
    $threads = $_ENV['MYLOADER_THREADS'] ?: self::THREADS;
    $queries = $_ENV['MYLOADER_QUERIES_PER_TRANSACTION'] ?: self::QUERIES_PER_TRANSACTION;
    
    $cmd = sprintf(
      'myloader \
--host="%s" \
--user="%s" \
--password="%s" \
--database="%s" \
--directory="%s" \
--threads="%d" \
--queries-per-transaction="%d" \
--overwrite-tables \
--verbose=3',
      $dbhost, $dbuser, $dbpass, $dbname, $dbdump_dir, $threads, $queries
    );
    $result = $this->command->runProcess($cmd);

    $this->command->logExecute(
      $result['success'] ?? FALSE,
      'Restore DB dump',
      $result['error'] ?? 'Failed to restore DB dump'
    );
    return $result['success'] ?? FALSE;
  }

}
