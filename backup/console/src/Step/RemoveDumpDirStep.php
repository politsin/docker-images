<?php

namespace App\Step;

/**
 * Remove dump.
 */
class RemoveDumpDirStep extends StepBase {

  private const DBDUMP_DIR = '/var/www/html/.db';

  /**
   * Run.
   */
  public function run() : bool {
    $this->command->sendMqttMessage('START', 'RemoveDumpDirStep');
    $this->command->sendMessage('Remove dump dir');

    $cmd = sprintf('rm -rf %s', self::DBDUMP_DIR);
    $result = $this->command->runProcess($cmd);
    $this->command->logExecute(
      $result['success'] ?? FALSE,
      sprintf('rm %s', self::DBDUMP_DIR),
      $result['error'] ?? sprintf('Failed to rm %s', self::DBDUMP_DIR)
    );

    if (!empty($result['success'])) {
      $this->command->sendMqttMessage('FINISH', 'RemoveDumpDirStep');
    }
    return $result['success'] ?? FALSE;
  }

}
