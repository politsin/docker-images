<?php

namespace App\Command;

use App\Step\ArchiveStep;
use App\Step\CreateDbDumpStep;
use App\Step\RemoveDumpFileStep;
use App\Step\SetTimezoneStep;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

/**
 * Echo.
 */
class ConnectionCommand extends CommandBase implements CommandInterface {

  /**
   * Config.
   */
  protected function configure() {
    $this->setName('connection')
      ->setDescription('Connection test');
  }

  /**
   * Exec.
   */
  protected function execute(
    InputInterface $input,
    OutputInterface $output
  ) : int {
    $this->io = new SymfonyStyle($input, $output);
    $this->sendMqttMessage('START', 'S3Backup');
    $this->sendMessage('Start backup', 'START');
    $this->sendMqttMessage('ERROR', 'ConnectionTest');

    $this->sendMessage('Finish backup', 'STOP');
    $this->sendMqttMessage('FINISH', 'S3Backup');
    return 0;
  }

  /**
   * Debug.
   */
  private function debug() : int {
    if (!(new SetTimezoneStep($this))->run()) {
      $this->sendMqttMessage('ERROR', 'SetTimezoneStep');
      return 101;
    }
    elseif (!(new CreateDbDumpStep($this))->run()) {
      $this->sendMqttMessage('ERROR', 'CreateDbDumpStep');
      return 102;
    }
    elseif (!(new ArchiveStep($this))->run()) {
      $this->sendMqttMessage('ERROR', 'ArchiveStep');
      (new RemoveDumpFileStep($this))->run();
      return 103;
    }
    elseif (!(new RemoveDumpFileStep($this))->run()) {
      $this->sendMqttMessage('ERROR', 'RemoveDumpFileStep');
      return 104;
    }
    return 0;
  }

}
