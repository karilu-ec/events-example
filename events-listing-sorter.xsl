<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  
  <!-- Used to figure out if we have a term or category listing. -->
  <xsl:variable name="eventsHeadingCount" select="count(//node()[@data-type = 'events-heading'])"/>
  
  <!-- Output the term heading along with the associated events -->
  <xsl:template match="*[@data-type = 'events-heading']">
    <xsl:variable name="start" select="@data-start"/>
    <xsl:variable name="end" select="@data-end"/>

    <!-- Display the term heading -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    
    <!-- Create a new, sorted listing between the heading's start/end time. -->
    <xsl:apply-templates mode="sortListing" select="//node()[@data-type = 'events']">    
      <xsl:with-param name="start" select="$start"/>
      <xsl:with-param name="end" select="$end"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Output the a sorted listing of events based on a start/end time. -->
  <xsl:template match="*[@data-type = 'events']" mode="sortListing">
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    
    <xsl:variable name="dataLimit">
      <xsl:choose>
        <xsl:when test="@data-limit != ''"><xsl:value-of select="@data-limit"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <!-- Only sort and display event items based on a start/end date and within the limit (if one exists). -->
        <xsl:when test="$start and $end">          
          <xsl:for-each select="child::node()[@data-timestamp &gt;= $start and @data-timestamp &lt;= $end]">
            <xsl:sort order="ascending" select="@data-timestamp"/>   
            <xsl:if test="$dataLimit = '' or $dataLimit = '0' or position() &lt;= number($dataLimit)">
              <xsl:apply-templates select="."/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <!-- Otherwise, sort and display all of the items within the limit (if one exists). -->
        <xsl:otherwise>            
            <xsl:for-each select="child::node()[@data-timestamp]">
              <xsl:sort order="ascending" select="@data-timestamp"/> 
              <xsl:if test="$dataLimit = '' or $dataLimit = '0' or position() &lt;= number($dataLimit)">
                <xsl:apply-templates select="."/>
              </xsl:if>
            </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- This template will remove the original, un-sorted listing headings are present. -->
  <xsl:template match="*[@data-type = 'events']"/>
  
  <!-- This template will display the full listing if listing headings are not present. -->
  <xsl:template match="*[@data-type = 'events' and $eventsHeadingCount = 0]">
      <xsl:apply-templates mode="sortListing" select="."/> 
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xhtml:head">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>