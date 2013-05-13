<?php
$string = <<<XML
<a>
  <foo name="one" game="lonely">1</foo>
  <fa>2</>
</a>
XML;

$xml = simplexml_load_string($string);
foreach ($xml->children()->attributes() as $a => $b) {
  echo $a . "=" . $b . "\n<br />";
}