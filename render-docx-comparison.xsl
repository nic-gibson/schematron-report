<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	exclude-result-prefixes="xs xd"
	xmlns:temp="urn:oecd:names:xmlns:transform:temp" xpath-default-namespace="urn:oecd:names:xmlns:transform:temp" 
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Feb 26, 2014</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Render the docx vs xml comparison as html</xd:p>
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
	
	<xsl:template match="/">
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
				<title>Comparison Report on: <xsl:value-of select="$report-on"/></title>
			</head>
			<body>
				<h1>Comparison Report on: <xsl:value-of select="$report-on"/></h1>
				<xsl:choose>
					<xsl:when test="not(block-pair)">
						<h2>XML and Word documents match!</h2>
					</xsl:when>
					<xsl:otherwise>
						<table>
							<thead>
								<tr>
									<td>XML</td>
									<td>Word</td>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="block-pair"/>		
							</tbody>
						</table>
								
					</xsl:otherwise>
				</xsl:choose>
				
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="block-pair[@style-match=0]" priority="1">
		<xsl:apply-templates select="." mode="style-mismatch"/>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template match="block-pair" mode="style-mismatch">
		<tr class="style-mismatch">
			<td><xsl:value-of select='block[1]/@style'/></td>
			<td><xsl:value-of select='@other-style'/></td>
		</tr>	
	</xsl:template>
	
	<xsl:template match="block-pair[block[1] = block[2]]">
		<tr>
			<td><xsl:apply-templates select="block[1]"/></td>
			<td>…</td>
		</tr>	
	</xsl:template>

	<xsl:template match="block-pair">
		<tr>
			<td><xsl:apply-templates select="block[1]"/></td>
			<td><xsl:apply-templates select="block[2]"/></td>
		</tr>	
	</xsl:template>
	
</xsl:stylesheet>