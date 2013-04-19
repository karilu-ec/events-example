<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="site://_standard2.1.1/_cascade/formats/XSLT/format-date"/>
  <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
  
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  
  <xsl:template name="build-documents-xml">
    <xsl:param name="page"/>
    
    <!-- 
    This variable is appended onto the end of page URLs. Change the value to correspond
    with the extensions of your pages (eg .html, .php, .aspx).
    -->
    <xsl:param name="pageExtension"/>
    
    <xsl:variable name="pageSDS" select="$page/system-data-structure"/>


        
    <admin-document>
      <title>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="$page/title"/>
          <xsl:with-param name="replace">'</xsl:with-param>
          <xsl:with-param name="with">&apos;</xsl:with-param>                                
        </xsl:call-template>
      </title>
      <id><xsl:value-of select="$page/@id"/></id>
      <target>[system-view:internal]true[/system-view:internal][system-view:external]false[/system-view:external]</target>
      <path>[system-view:external]<xsl:value-of select="$page/path"/><xsl:value-of select="$pageExtension"/>[/system-view:external][system-view:internal][system-asset]<xsl:value-of select="$page/path"/>[/system-asset][/system-view:internal]</path>
     
     <document-date>
        <xsl:call-template name="format-date">
          <xsl:with-param name="date" select="$pageSDS/document-date"/>
          <xsl:with-param name="mask" select="'shortDate'"/>
        </xsl:call-template>
      </document-date>
    
      <cancellation-date>
        <xsl:if test="$pageSDS/cancellation-date != ''">
          <xsl:call-template name="format-date">
            <xsl:with-param name="date" select="$pageSDS/cancellation-date"/>
            <xsl:with-param name="mask" select="'shortDate'"/>
          </xsl:call-template>
        </xsl:if>
      </cancellation-date>
      <alternate-cancellation-date>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="$pageSDS/alternate-cancellation-date"/>
          <xsl:with-param name="replace">'</xsl:with-param>
          <xsl:with-param name="with">&apos;</xsl:with-param>                                
        </xsl:call-template>
      </alternate-cancellation-date>
      <originator>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="$pageSDS/originator"/>
          <xsl:with-param name="replace">'</xsl:with-param>
          <xsl:with-param name="with">&apos;</xsl:with-param>
        </xsl:call-template>
      </originator>
      <admin-file>
        <path><xsl:value-of select="$pageSDS/admin-file/path"/></path>
        <link><xsl:value-of select="$pageSDS/admin-file/link"/></link>                
      </admin-file>      
    </admin-document>
  </xsl:template>
    
  <xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="stringtolower">
    <xsl:param name="string"/>
    <xsl:value-of select="translate($string, $uppercase, $lowercase)"/>
  </xsl:template>
    
</xsl:stylesheet>