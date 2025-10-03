<?php

namespace App\Step;

/**
 * Remove dump.
 */
class RemoveDumpStep extends StepBase {

  /**
   * Run.
   */
  public function run() : bool {
    if (empty($_ENV['DBDUMP'])) {
      $this->command->sendMessage('Without dbdump');
      return TRUE;
    }
    $this->command->sendMqttMessage('START', 'RemoveDumpStep');
    $this->command->sendMessage('Remove dump');

    $result = FALSE;
    if ($_ENV['DBDUMP'] == 'mydumper') {
      $result = (new RemoveDumpDirStep($this->command))->run();
    }
    else {
      $result = (new RemoveDumpFileStep($this->command))->run();
    }

    if ($result) {
      $this->command->sendMqttMessage('FINISH', 'RemoveDumpStep');
    }
    return $result['success'] ?? FALSE;
  }

}
