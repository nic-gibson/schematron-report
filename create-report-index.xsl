<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:manifest="urn:oecd:names:xmlns:transform:manifest"
 	  xpath-default-namespace="urn:oecd:names:xmlns:transform:manifest"
	exclude-result-prefixes="xs xd"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Feb 26, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Read the manifest file and create an index page for the reports.</xd:p>
		</xd:desc>
	</xd:doc>
	
	
	<xd:doc>
		<xd:desc>Set this to generate the appropriate report title</xd:desc>
	</xd:doc>
	<xsl:param name="report-on" select="'Unknown Document'"/>
	
	<xd:doc>
		<xd:desc> Set this to 'insert' to load the stylesheet and any other value to reference
			it.</xd:desc>
	</xd:doc>
	<xsl:param name="css-mode" select="'insert'"/>
	
	<xd:doc>
		<xd:desc>Change this to the URL for the stylesheet.</xd:desc>
	</xd:doc>
	<xsl:param name="css-url" select="resolve-uri('../css/svrl-report.css', $where-am-i)"/>
	
	<!-- set this to override the default title -->
	<xsl:param name="report-title" select="'Schematron Processing Output Report'"/>
	
	<!-- use this to set the location of the import files in the output stylesheet -->
	<xsl:variable name="where-am-i" select="base-uri(document(''))"/>
	
	<xsl:param name="output-root"/>
	<xsl:param name="suffix" select="'.report.html'"/>
	
	<xsl:template match="manifest">
		<html>
			<head>
				<xsl:choose>
					<xsl:when test="$css-mode != 'insert'">
						<link href="{{$css-url}}" type="text/css" rel="stylesheet"/>
					</xsl:when>
					<xsl:otherwise>
						<style type="text/css">
							<xsl:value-of select="unparsed-text($css-url)"/>
						</style>
					</xsl:otherwise>
				</xsl:choose>
				<title>Report Index</title>
			</head>
			<body>
				<h1>Report Index</h1>
				<xsl:apply-templates select="item">
					<xsl:sort select="@href"/>
				</xsl:apply-templates>				
			</body>
		</html>
		
	</xsl:template>
	
	<xsl:template match="item">
		<div class="report-item">
			<xsl:apply-templates select="@href" mode="caption"/>
			<ul><xsl:apply-templates select="@*"/></ul>
		</div>
	</xsl:template>
	
	<xsl:template match="@href" mode="caption">
		<h4><xsl:value-of select="."/></h4>
	</xsl:template>
	
	<xsl:template match="@href">
		<li><a>
			<xsl:apply-templates select="." mode="generate-href"/>
			Validation Report</a></li>
	</xsl:template>
	
	<xsl:template match="@docx-href">
		<li><a>
			<xsl:apply-templates select="." mode="generate-href"/>
			Word Comparison Report</a></li>
	</xsl:template>
	
	<xsl:template match="@submitted-href">
		<li><a>
			<xsl:apply-templates select="." mode="generate-href"/>
			Submitted File Validation Report</a></li>
	</xsl:template>
	
	<xsl:template match="@*" mode="generate-href">
		<xsl:variable name="cleaned" select="string-join(
			for $part in tokenize(., '/') return replace($part, '[^\w]', '_'),
			'/')"></xsl:variable>
		<xsl:attribute name="href" select="concat($cleaned, $suffix)"/>
	</xsl:template>
	
</xsl:stylesheet>