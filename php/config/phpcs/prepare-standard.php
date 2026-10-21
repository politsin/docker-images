<?php

// Legacy Coder releases do not contain every newer comment sniff. PHPCS
// rejects even an exclusion referring to a missing sniff, so retain only
// exclusions that exist in the version installed for this PHP branch.
$path = '/var/lib/composer/phpcs.xml';
$document = new DOMDocument();
$document->preserveWhiteSpace = false;
$document->formatOutput = true;
$document->load($path);
$remove = [];
foreach ($document->getElementsByTagName('exclude') as $exclude) {
    $name = $exclude->getAttribute('name');
    $parts = explode('.', $name);
    if (count($parts) === 3 && $parts[0] === 'Drupal') {
        $sniff = '/var/lib/composer/vendor/drupal/coder/coder_sniffer/Drupal/Sniffs/'
            . $parts[1] . '/' . $parts[2] . 'Sniff.php';
        if (!is_file($sniff)) {
            $remove[] = $exclude;
            echo 'Skip exclusion for unavailable legacy sniff: ' . $name . PHP_EOL;
        }
    }
}
foreach ($remove as $exclude) {
    $exclude->parentNode->removeChild($exclude);
}
$document->save($path);
