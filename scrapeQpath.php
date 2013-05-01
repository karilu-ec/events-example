<?php
//look at https://fedorahosted.org/querypath/wiki/ReallySimpleSyndication for the creation of the xml from the array.
require 'querypath/src/qp.php';
$url = 'http://www.usna.edu/AdminSupport/notices/index1.html';
$arrayTitles = array("Number", "date", "Cancelation date", "subject", "originator");
$qp = htmlqp($url, 'table')->children('tr');
$record = qp('<?xml version="1.0"?><data></data>');
 
   foreach ($qp as $row_value) {
      $column = $row_value->children('td');
      foreach ($column as $index=>$columnText) {
        //echo  $arrayTitles[$index].":" . htmlspecialchars($columnText->text()).  "<br/>";
      
      }
      
    }
?>

