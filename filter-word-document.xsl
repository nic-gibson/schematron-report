<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:cw="http://www.corbas.co.uk/ns/word"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns="urn:oecd:names:xmlns:transform:temp"
	exclude-result-prefixes="xs xd w cw"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 29, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Strip down the content of a word document to blocks of text
			with style names. </xd:p>
			<xd:p><xd:b>WARNING - only paragraph content handled  in this version.</xd:b></xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:output indent="yes"></xsl:output>
	<xsl:strip-space elements="*"/>
	<xsl:preserve-space elements="w:t"/>
	
	<xd:doc>
		<xd:desc>Any para with one of these styles will be suppressed.</xd:desc>
	</xd:doc>
	<xsl:param name="styles-to-ignore" select="('Structural', 'Empty')"/>


	<xd:doc>
		<xd:desc>Convert the document itself into a list of blocks. We do this in two stages. Firstly, we
		strip off and simplify so that the result is a list of paras with runs inside them and the style
		name assigned to the para. The second stage converts the runs to text.</xd:desc>
	</xd:doc>
	<xsl:template match="/">
		<document>
			<xsl:variable name="simplified" as="element()*"><xsl:apply-templates select="//w:body//w:p" mode="simplify"/></xsl:variable>
			<xsl:apply-templates select="$simplified"/>	
			
		</document>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Simplify paragraphs down to style attributes and simplified runs.</xd:desc>
	</xd:doc>
	<xsl:template match="w:p" mode="simplify">
		<xsl:copy>
			<xsl:apply-templates select="w:pPr" mode="simplify"/>
			<xsl:apply-templates select="w:r" mode="simplify"/>
		</xsl:copy>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Convert a run to a simpler form - losing the text elements and properties.</xd:desc>
	</xd:doc>
	<xsl:template match="w:r" mode="simplify">
		<w:r><xsl:apply-templates select="*" mode="#current"/></w:r>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Convert </xd:desc>
	</xd:doc>
	<xsl:template match="w:t[normalize-space(replace(., '&#xA0;', ' ')) = '']" mode="simplify" priority="1"/>
	
	<xsl:template match="w:t" mode="simplify">
		<xsl:value-of select="normalize-space(replace(., '&#xA0;', ' '))"/>
	</xsl:template>
	
	<xsl:template match="w:tab" mode="simplify">
		<xsl:text>&#x20;</xsl:text>
	</xsl:template>
	
	<xsl:template match="w:t[@xml:space='preserve']" mode="simplify" priority="2">
		<xsl:variable name="prefix" select="if (matches(., '^[\s&#xA0;]')) then ' ' else ''"/>
		<xsl:variable name="suffix" select="if (matches(., '[\s&#xA0;]$')) then ' ' else ''"/>
		<xsl:variable name="content" select="normalize-space(.)"/>
		<xsl:value-of select="concat($prefix, $content, $suffix)"/>
	</xsl:template>
	
	<xsl:template match="w:p">
		<xsl:variable name='runs' as="xs:string*">
			<xsl:apply-templates select="w:r" />
		</xsl:variable>
		<xsl:variable name="content" select="normalize-space(string-join($runs, ''))"/>
		<xsl:if test="$content">
		<block style="{@style}"><xsl:value-of select="$content"/></block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="w:p[@style = $styles-to-ignore]" priority="10"/>
	
	<xsl:template match="w:r" as="xs:string">
		<xsl:value-of select="replace(text(), '&#xA0;', ' ')"/>
	</xsl:template>
	
	<xsl:template match="w:pPr" mode="simplify">
		<xsl:apply-templates mode="simplify"/>
	</xsl:template>
	
	<xsl:template match="w:pPr/node()" mode="simplify"/>
	
	<xsl:template match="w:pPr/w:pStyle" priority="1" mode="simplify">
		<xsl:variable name="id" select="@w:val" as="xs:string" />
		<xsl:variable name="style" select="/cw:word-doc/w:styles/w:style[@w:styleId = $id]"/>
		<xsl:attribute name="style" select="$style/w:name/@w:val"/>
	</xsl:template>
	
</xsl:stylesheet>