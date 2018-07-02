<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:cfn="http://www.corbas.co.uk/ns/xsl/functions"
	exclude-result-prefixes="xs xd"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 28, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Convert the content of a Google docs spreadsheet in 
			CSV to a simple XML format using Andrew Welch's simple XSLT based parser. This
			should be called by setting the initial template to 'process-csv'.</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xd:doc>
		<xd:desc>The responses-url parameter defines the URI to be download. The response
		should be a CSV file to be parsed into records.</xd:desc>
	</xd:doc>
	<xsl:param name="responses-url" as="xs:anyURI"/>
	
	<xsl:template name="process-csv">
		<xsl:choose>
			<xsl:when test="unparsed-text-available($responses-url)">
				
				<xsl:variable name="lines" as="element()+">
					<xsl:call-template name="build-lines">
						<xsl:with-param name="lines" select="tokenize(unparsed-text($responses-url), '\r?\n')"/>
					</xsl:call-template>
				</xsl:variable>
				
				<form>
					<xsl:apply-templates select="$lines[position()=1]" mode="header"/>
					<xsl:apply-templates select="$lines[not(position() = 1)]"/>
				</form>
				
			</xsl:when>
			<xsl:otherwise>
				<!-- NOTE: not sure this is the right error code -->
				<xsl:value-of select="error(QName('http://www.w3.org/2005/xqt-error', 'err:FODC0002'), 
					concat('Unbable to load ', $responses-url))"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xd:doc>
		<xd:desc>Converts a sequence of lines into a sequence of line elements are returns it.</xd:desc>
	</xd:doc>
	<xsl:template name="build-lines" as="element()+">
		<xsl:param name="lines" as="xs:string*" select="()"/>
		<xsl:for-each select="$lines">
			<line><xsl:value-of select="."/></line>
		</xsl:for-each>	
	</xsl:template>
	
	
	<xd:doc>
		<xd:desc>Convert a single line into a sequence of field elements. This is
		used for the data lines</xd:desc>
	</xd:doc>
	<xsl:template match="line">
		<record>
			<xsl:variable name="tokens" select="cfn:get-tokens(.)"/>
			<xsl:for-each select="$tokens">
				<field><xsl:value-of select="."/></field>
			</xsl:for-each>
		</record>
	</xsl:template>
	
	
	<xd:doc>
		<xd:desc>Convert the header line into a header record.</xd:desc>
	</xd:doc>
	<xsl:template match="line" mode="header">
		<header>
			<xsl:variable name="tokens" select="cfn:get-tokens(.)"/>
			<xsl:for-each select="$tokens">
				<field><xsl:value-of select="."/></field>
			</xsl:for-each>
		</header>
	</xsl:template>	
	
	
	<xd:doc>
		<xd:desc>Convert a string of CSV data into a sequence of tokens.</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:get-tokens" as="xs:string+">
		<xsl:param name="str" as="xs:string" />
		<xsl:analyze-string select="concat($str, ',')" regex='(("[^"]*")+|[^,]*),'>
			<xsl:matching-substring>
				<xsl:sequence select='replace(regex-group(1), "^""|""$|("")""", "$1")' />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
</xsl:stylesheet>