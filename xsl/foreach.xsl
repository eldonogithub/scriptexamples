<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="TAG">
    <TABLE>
      <TR ID="@ID">
        <xsl:for-each select="(document('')//*)[position() &lt;= Value]">
          <TD>
          </TD>
        </xsl:for-each>
      </TR>
    </TABLE>
  </xsl:template>
</xsl:stylesheet>