<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:doc="urn:oecd:names:xmlns:authoring:document"
	xmlns:ofn="urn:oecd:names:xmlns:transform:functions"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	 xpath-default-namespace="urn:oecd:names:xmlns:authoring:document"
	
	exclude-result-prefixes="xs xd"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Feb 24, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Determine the document type of an OECD document by examining metadata
			and processing instructions if required. If a document type cannot be found,
			defaults to 'official document'</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:template match="/">
		<xsl:variable name="default">
			<c:result>Official Document</c:result>
		</xsl:variable>
		<xsl:copy-of select="(ofn:doctype-from-meta(/), ofn:doctype-from-pi(/), $default)[1]"/>
	</xsl:template>
	
	
	<xsl:function name="ofn:doctype-from-pi" as="element(c:result)?">
		<xsl:param name="the-doc" as="document-node()"/>
		<xsl:variable name="type-map" as="element()*">
			<ofn:map pi="official-document" type="Official Document"/>
			<ofn:map pi="agenda" type="Agenda"/>
			<ofn:map pi="publication" type="Publication"/>
		</xsl:variable>
		<xsl:variable name="pi" select="$the-doc/processing-instruction('Xpress')"/>
		<xsl:choose>
			<xsl:when test="$pi">
				<xsl:analyze-string select="$pi" regex="productLine=&quot;([^&quot;]+)">
					<xsl:matching-substring>
						<c:result><xsl:value-of select="$type-map[@pi = lower-case(regex-group(1))]/@type"/></c:result>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="()"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<xsl:function name="ofn:doctype-from-meta" as="element(c:result)?">
		<xsl:param name="the-doc" as="document-node()"/>
		<xsl:variable name="meta" select="($the-doc//document-metadata//metadata-item[@property = 'oecd:contentType'],
			$the-doc//document-metadata//metadata-item[@property = 'oecd:docType'])[1]"/>
		<xsl:choose>
			<xsl:when test="$meta">
				<c:result><xsl:value-of select="$meta/@value"/></c:result>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>