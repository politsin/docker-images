<?php

/**
 * @file
 * While true print memory usage.
 */

while (TRUE) {
  $memory = memory_get_usage();
  $date = (new DateTime('now'))->format('H:i:s.v');
  echo "$date | $memory bytes\n";
  // Microseconds.
  usleep(5 * 1000);
}
