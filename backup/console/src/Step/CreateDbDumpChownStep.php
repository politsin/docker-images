<?php

namespace App\Step;

/**
 * Create dump.
 */
class CreateDbDumpChownStep extends StepBase {

  const SITE_ROOT = '/var/www/html';
  const DUMP_FILE_NAME = '.db.sql';
  const DBDUMP_DIR = '.db';

  /**
   * Run.
   */
  public function run() : bool {

    if ($_ENV['DBDUMP'] == 'mydumper') {
      $dbdump_dir = $_ENV['DBDUMP_DIR'] ?: implode('/', [self::SITE_ROOT, self::DBDUMP_DIR]);
  
      $cmd = sprintf('chown www-data:www-data %s', $dbdump_dir);
    }
    else {
      $dbfile = $_ENV['DBFILE'] ?? implode('/', [self::SITE_ROOT, self::DUMP_FILE_NAME]);
  
      $cmd = sprintf('chown www-data:www-data %s', $dbfile);
    }
    
    $result = $this->command->runProcess($cmd);

    $this->command->logExecute(
      $result['success'] ?? FALSE,
      'CHOWN www-data',
      $result['error'] ?? 'Failed to CHOWN www-data'
    );
    return $result['success'] ?? FALSE;
  }

}
