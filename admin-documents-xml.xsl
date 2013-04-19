<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="/_cascade/format/admin-documents-xml-builder"/>
  <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
  
  <!-- 
    This variable is appended onto the end of page URLs. Change the value to correspond
    with the extensions of your pages (eg .html, .php, .aspx).
  -->
  <xsl:variable name="pageExtension">.php</xsl:variable>

  <xsl:variable name="folderPrefix">/</xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="currentPage" select="//system-page[@current]"/>
    <xsl:variable name="fixedPath" select="translate(substring-before($currentPage/path, $currentPage/name),'/','')"/>

    <xml>
      <xsl:choose>
        <!-- If we're within a note|inst/xxxx-xxxx folder, grab single documents from the current folder. -->
        <xsl:when test="string-length($fixedPath) &gt; 4">
          <xsl:apply-templates select="//system-page[not(@current) and system-data-structure/@definition-path='Document-Data']">
            <xsl:sort select="document-date"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- If we're within a notices|instructions folder, grab documents from each number folder. -->
        <xsl:when test="string-length($fixedPath) = 4">
          <xsl:apply-templates select="//system-page[not(@current) and name != 'index' and contains(path, $fixedPath)]">
            <xsl:sort select="document-date"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- Otherwise, do nothing. -->
        <xsl:otherwise/>    
      </xsl:choose>
    </xml>
  </xsl:template>
  <xsl:template match="system-page">
      <xsl:call-template name="build-documents-xml">
          <xsl:with-param name="page" select="."/>
          <xsl:with-param name="pageExtension" select="$pageExtension"/>          
      </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>