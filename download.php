<?php

use Symfony\Component\Process\Process;

require __DIR__ . '/vendor/autoload.php';

$remotePath = 'https://speed.hetzner.de/100MB.bin';

function downloadViaCurl($remotePath)
{
    $commandline = sprintf(
        'curl -o %s %s',
        '/tmp/file.bin',
        $remotePath
    );

    $process = new Process($commandline);
    $process->disableOutput();
    $process->setTimeout(null);
    $process->run();
}

function downloadViaPHP($remotePath)
{
    $contents = file_get_contents($remotePath);
    file_put_contents('/tmp/file.csv', $contents);
}

echo PHP_EOL . "Via cURL:" . PHP_EOL;

downloadViaCurl($remotePath);

$memory = memory_get_peak_usage(false) / 1000000;
echo sprintf("Used %.2fMB of RAM" . PHP_EOL, $memory);
