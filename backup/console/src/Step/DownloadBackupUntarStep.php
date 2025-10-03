<?php

namespace App\Step;

/**
 * Untar backup.
 */
class DownloadBackupUntarStep extends StepBase {

  /**
   * Run.
   */
  public function run() : bool {
    $file = $this->command->local_tarball_path;
    $options = $_ENV['BACKUP_TAR_OPTION_RESTORE'] ?? '';
    $cmd = "tar xzf $file -C / $options";
    $result = $this->command->runProcess($cmd);

    $this->command->logExecute(
      $result['success'] ?? FALSE,
      'Unpack backup',
      $result['error'] ?? 'Failed to unpack Last Backup'
    );

    return $result['success'] ?? FALSE;
  }

}
