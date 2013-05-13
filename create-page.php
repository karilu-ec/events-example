<?php
date_default_timezone_set("UTC");
echo "Process started at ".date("m/d/y H:i:s",time())."\r\n";

$username = "ksimpson";
$password = "C3c1liaI\$abeL@";
$cascadePath = "https://cascade.usna.edu";

$cascade = new SoapClient($cascadePath . "/ws/services/AssetOperationService?wsdl",array('trace' => 1));

$pageVariables = getDataStructure();

foreach ($pageVariables as $pageData) {
  createPage($username, $password, $cascade, $pageData);
}

/*
//Create the folder for the documents
$folderName=array ('2000-2999','3000-3999','4000-4999', '5000-5999', '6000-6999', '7000-7999', '8000-8999', '9000-9999', '10000-10999',  '11000-11999', '12000-12999' );
foreach ($folderName as $folderName) {
  createFolder($username, $password, $cascade, $folderName);
}*/


//Scraping the notices and instructions for AdminSupport
function getDataStructure() {
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
        $value = trim(htmlentities(str_replace($search, "", $columnText->text()), ENT_QUOTES, "UTF-8"));        
        $valueConverted = strtr($value, array_flip(get_html_translation_table(HTML_ENTITIES, ENT_QUOTES)));
        $value = trim($valueConverted,chr(0xC2).chr(0xA0));
        
        if ($index == 1) {
         $value = $value . " 08:00:00";//adding time to the date.
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
  return $results;
}

function createFolder($username, $password, $cascade, $folderName){
  $siteId = '18af442a0a014d0b57a165ca48e3dd7e'; //substitute site ID here
  $folder_params = array(
    'authentication' => array(
       'username' => $username,
       'password' => $password),
    'asset' => array(
      'folder' => array(
        'name' => $folderName,
        'siteId' => $siteId,
        'metadataSetId' => '755f41780a014d0b696edf950bcbd45e', //Default from _standard2.1.1
        'parentFolderId' =>'31d51afd0a014d0b57a165ca6a576fb3' //Substitue your parent folder here.
      )
    )
  );
  //create folder
  $cascade->create($folder_params);
  $result = $cascade->__getLastResponse();
  getResult($result);

}

function createPage($username, $password, $cascade, $pageData){
  $contentTypeId = '1ddd583a0a014d0b57a165cafc620226'; //substitute content type ID here
  $parentFolderId = '7bdeb9830a014d0b2d510b030b9f4349'; //12000. Substitute parent folder ID here
  $siteId = '18af442a0a014d0b57a165ca48e3dd7e'; //substitute site ID here
  $filesFolder = "/_files/documents/instructions/"; //substitute the file path for the docs attached to the node.
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
  $typeDocument = "Inst";//either Note or Inst 
  $subject = preg_replace($patterns,$replacements, $pageData['subject']);
  $name = utf8_encode($pageData['number'].'-'. preg_replace('/\-(-)+/','-', $subject));  
  $title =utf8_encode($pageData['subject']);
  $number =utf8_encode($pageData['number']);
  $documentDate = floatval($pageData['document-date'].'000'); //cascade uses timestamp of 13 digits. So I'm adding 000 as microtime()
  $originator = utf8_encode($pageData['originator']);
  if(!empty($pageData['alternate-cancellation-date'])) {
    $alternateCancellationDate = utf8_encode($pageData['alternate-cancellation-date']);
    $typeDocument = "Note";// Notes have a cancellation date.
  } else{
    $alternateCancellationDate='';
  }
  
  $filePath = utf8_encode($filesFolder . $pageData['file-path']);
  $typeDocument = "Inst";//either Note or Inst 
  
  $template_params = array(
      'authentication' => array(
          'username' => $username,
          'password' => $password),
      'asset' => array(
          'page' => array(
              'contentTypeId' => $contentTypeId,              
              'parentFolderId' => $parentFolderId,
              'siteId' => $siteId,
              'name' => $name,
              'metadata' => array(    
                'title' => $title,
                'dynamicFields' => array(
                  'dynamicField' => array(
                    'name' => 'document-category',
                    'fieldValues' => array(
                      'fieldValue' => array(
                        'value' => $typeDocument
                      ),
                    ),
                  ),
                ),
              ),
              'structuredData' => array(    
                'definitionPath' => "/Document-Data",    
                 'structuredDataNodes' => array(                      
                    'structuredDataNode' => array(    
                     array(    
                      'type' => "text",    
                      'identifier' => "number",    
                      'text' =>$number),    
                          
                    array(    
                      'type' => "text",    
                      'identifier' => "document-date",    
                      'text' => $documentDate),    
                          
                    array(    
                      'type' => "text",    
                      'identifier' => "alternate-cancellation-date",    
                      'text' => $alternateCancellationDate),
                    array(
                      'type' => "text",    
                      'identifier' => "originator",    
                      'text' => $originator),
                    array(
                      'type' => "asset",    
                      'identifier' => "admin-file",    
                      'assetType' => "file",
                      'filePath' => $filePath)
                      )
                  )
              )
          )
          
        )
      );
              
  $cascade->create($template_params);
  $result = $cascade->__getLastResponse();
  getResult($result);
}

function getResult($result)
{
	if (!isSuccess($result))
	{
		echo "\r\nError";
		echo "\r\n".extractMessage($result)."\r\n";
	}	
	else
	{
		echo "Success!";
	}
}

function isSuccess($text)
{
	return substr($text, strpos($text, "<success>")+9,4)=="true";
}
function extractMessage($text)
{
	return substr($text, strpos($text, "<message>")+9,strpos($text, "</message>")-(strpos($text, "<message>")+9));
}
?>