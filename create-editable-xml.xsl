<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="urn:oecd:names:xmlns:authoring:document" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:temp="urn:oecd:names:xmlns:authoring:temp"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mml="http://www.w3.org/1998/Math/MathML"
	 xpath-default-namespace="urn:oecd:names:xmlns:authoring:document"
	 xmlns:cfn="http://www.corbas.co.uk/ns/xsl/functions"
	exclude-result-prefixes="xs xd"
	version="2.0">
	
	<xsl:import href="uuid.xsl"/>
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 18, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
	
	<xsl:param name="uuid-count" select="count(//*)"/>
	
	
	<xsl:template match="/">
		
		<xsl:variable name="post-id">
			<xsl:apply-templates mode="add-id"/>
		</xsl:variable>
		
		<xsl:apply-templates select="$post-id"/>
				
	</xsl:template>
	
	<xsl:template match="comment()|processing-instruction()|text()|@*" mode="#all">
		<xsl:copy/>
	</xsl:template>
	
	
	<xsl:template match="*" mode="add-id">
		<xsl:variable name="seq-num">
			<xsl:number count="*" level="any"/>
		</xsl:variable>
		<xsl:copy> 
			<xsl:apply-templates select=".[not(@xml:id)]" mode="insert-id">
				<xsl:with-param name="seq-num" select="$seq-num"/>
			</xsl:apply-templates>
			<xsl:apply-templates select=".[not(@class)]" mode="add-class"/>
			<xsl:apply-templates select="@*|node()" mode="add-id"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- ID INSERTION -->
	<xsl:template match="*" mode="insert-id">
		<xsl:param name="seq-num"/>
		<xsl:message><xsl:value-of select="$seq-num"/></xsl:message>
		<xsl:attribute name="xml:id" select="concat('id-', lower-case(cfn:get-uuid($seq-num)))"/>
	</xsl:template>
	
	<xsl:template match="para/*|equation/*|title/*|mml:*" mode="insert-id"/>
	<xsl:template match="block-quote/para" mode="insert-id"/>
	<xsl:template match="document-metadata|metadata" mode="insert-id"/>
	
	
	<!-- ADD REQUIRED CLASS ATTRIBUTES -->
	<xsl:template match="*"  mode="add-class"/>
	
	<xsl:template match="para" mode="add-class">
		<xsl:attribute name="class" select="'body'"/>
	</xsl:template>
	
	<xsl:template match="title" mode="add-class">
		<xsl:attribute name="class" select="'title'"/>
	</xsl:template>
	
	<xsl:template match="table" mode="add-class">
		<xsl:attribute name="class" select="'table'"/>
	</xsl:template>
	
	
	<!-- GENERAL FIXUPS -->
	
	<xsl:template match="document/title[not(node())]">
		<title>ENTER DOCUMENT TITLE</title>
	</xsl:template>
	
	<xsl:template match="chapter/title[not(node())]">
		<title>[CHAPTER TITLE]</title>
	</xsl:template>
	
	<xsl:template match="table/titles">
		<xsl:apply-templates/>
	</xsl:template>
	

</xsl:stylesheet>