<!doctype html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>Document</title>
</head>
<body>
   <?php
   date_default_timezone_set("UTC");
//look at https://fedorahosted.org/querypath/wiki/ReallySimpleSyndication for the creation of the xml from the array.
require 'querypath/src/qp.php';
  $url = 'http://www.usna.edu/AdminSupport/instructions/index12.html'; //Subsitute the URL of the page to scrape here.
  if (strpos($url, "instructions")=== false) {
    $arrayTitles = array("number", "document-date", "alternate-cancellation-date", "subject", "originator");  
  }
  else {
    $arrayTitles = array("number", "document-date", "subject", "originator");  
  }
  
$qp = htmlqp($url, 'table')->children('tr');

$page_variables=array();
$search=array("\r\n", "\n", "\r");
 
   foreach ($qp as $row_value) {
      $column = $row_value->children('td');
      foreach ($column as $index=>$columnText) {              
        //$value= trim(trim(htmlspecialchars($columnText->text()), chr(0xC2).chr(0xA0)));
        $value = trim(htmlentities(str_replace($search, "", $columnText->text()), ENT_QUOTES, "UTF-8"));        
        $valueConverted = strtr($value, array_flip(get_html_translation_table(HTML_ENTITIES, ENT_QUOTES)));
        $value = trim($valueConverted,chr(0xC2).chr(0xA0));
        
        if ($index == 1) {
         $value = $value . " 12:00:00";//adding time to the date.
         $value = strtotime($value); //convert date to timestamp
        }
        $page_variables[$arrayTitles[$index]] = $value;
        if($index==0) {
          $filePath = $columnText->find('a')->attr('href'); //find the filename from the first column
          $page_variables["file-path"] = $filePath;
        }
      }
      if (!empty($page_variables)) {
         $results[] =  $page_variables;
      }
   }
   
   foreach($results as $pageData) {
      $patterns=array();
      $patterns[0] = '/\s+/';
      $patterns[1] = '/\'|"|\/|\+|,|\./';
      $patterns[2] = '/\((.*)\)/';
      $patterns[3] = '/\bfor|and|to|the|or|in|:|at|of\b/';
      $patterns[4] = '/&/';
      $replacements = array();
      $replacements[0] = '-';
      $replacements[1] = '';
      $replacements[2] = '';
      $replacements[3] = '';
      $replacements[4] = '';
      $subject = preg_replace($patterns,$replacements, $pageData['subject']);
      $name = utf8_encode($pageData['number'].'-'. preg_replace('/\-(-)+/','-', $subject));
      echo "Name = " . $name . "<br>\n";
      echo "Originator = " . $pageData['originator'] . "<br>\n";
      $timeVal= $pageData['document-date'].'000';
      $timeVal = floatval($timeVal);
      echo "Document time = " . $timeVal. "<br>\n";
      //echo "Document date=" . date("Y-m-d H:i:s", $timeVal )."<br />\n";
     
   }
   
   //echo "date of timestamp = 1365768000000 is:".date("Y-m-d H:i:s", 1365768000000). PHP_EOL;
   //echo "date of timestamp = 1365768000 is:".date("Y-m-d H:i:s", 1365768000);
   
//var_dump($results);
?>

</body>
</html>

