<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:cfn="http://www.corbas.co.uk/xsl/functions"
	
	exclude-result-prefixes="xs xd"
	version="2.0">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 1, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Parse an XML file as text to insert markers into the nodes just before the validate errors.  This
			stylesheet depends on the saxon:parse extension function. The processed text is returned as the output
			having been parsed into an XDM tree.</xd:p>
		</xd:desc>
	</xd:doc>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Pass the URL for the file being validated as the xml-file parameter.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="xml-file" as="xs:string"/>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Load the unparsed text of the xml document</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:variable name="invalid-doc" select="if (unparsed-text-available($xml-file)) then unparsed-text($xml-file) else ''"/>
	

	<xd:doc>
		<xd:desc>The above content processed into multiple lines.</xd:desc>
	</xd:doc>
	<xsl:variable name="document-lines-initial" select="tokenize($invalid-doc, '&#013;?&#010;')"/>
	
	<xsl:template match="c:errors">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="c:error[not(@type = 'warning')]"/>
		</xsl:copy>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Process a c:error element by processing the content to extract column and row numbers and the
			element name. Pass this to the function that inserts a marker. </xd:p>
			<xd:p>Having done that, process the next sibling c:error element. This allows the string to be passed along
			each error node.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="c:error">
		<xsl:param name="document-lines" select="$document-lines-initial"/>
		<xsl:variable name="node" select="."/>
		<xsl:analyze-string select="." regex="element\s+[&lt;']([\w.-]+)[&gt;']" flags="i">
			<xsl:matching-substring>
				<xsl:variable name="line-number" select="xs:integer($node/@line)"/>
				<xsl:variable name="error-line" select="$document-lines[$line-number]"/>
				<xsl:variable name="col-number" select="if ($node/@column) then xs:integer($node/@column) else string-length($error-line)"/>
				<xsl:apply-templates select="$node" mode="reparse">
					<xsl:with-param name="document-lines" select="cfn:insert-marker(
						$line-number, 
						$col-number, 
						regex-group(1), 
						$node/text(), 
						$document-lines)"/>
				</xsl:apply-templates>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Reparse a document that has an inserted marker to get an XPath to the node *after* the marked one.</xd:desc>
	</xd:doc>
	<xsl:template match="c:error" mode="reparse">
		<xsl:param name="document-lines" as="xs:string*"/>
		<xsl:variable name="temp-doc" select="saxon:parse(string-join($document-lines, ''))" as="document-node()"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="select">
				<xsl:apply-templates select="$temp-doc//*[@__validation_marker]" mode="get-full-xpath"/>
			</xsl:attribute>
			<xsl:copy-of select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="cfn:insert-marker" as="xs:string*">
		<xsl:param name="row-num" as ="xs:integer"/>		<!-- row number from xsd error -->
		<xsl:param name="col-num" as="xs:integer"/>			<!-- col number from xsd error -->
		<xsl:param name="element-name" as="xs:string"/>		<!-- element name from xsd error -->
		<xsl:param name="error-message" as="xs:string"/>	<!-- text of error message -->
		<xsl:param name="document-lines" as="xs:string*"/>	<!-- current list of lines from input -->
		
		<!-- all lines before the current one -->
		<xsl:variable name="preceding-lines" select="if ($row-num > 1) then subsequence($document-lines, 1, $row-num - 1) else ()"/>
		
		<!-- all the lines after the current one -->
		<xsl:variable name="trailing-lines" select="subsequence($document-lines, $row-num + 1)"/>
		
		<!-- split the line into up to the column number and after it, $col-num is zero if we want to examine the whole line -->
		<xsl:variable name="to-error" select="if ($col-num gt 0) then substring($document-lines[$row-num], 1, $col-num) else $document-lines[$row-num]" as="xs:string"/>
		<xsl:variable name="after-error" select="if ($col-num gt 0) then substring($document-lines[$row-num], $col-num + 1) else ''" as="xs:string"/>
		
		<!-- construct the regular expression to match the last occurence of the element in a line. The
			matching element could be in the $to-error string or in any of the $lines-to-test lines. 
			Process these backwards to find the first matching line (this would be simpler is xpath 3) -->
		<xsl:variable name="matching-regex" as="xs:string" select="cfn:last-element-regex($element-name)"/>
		
		<!-- if the regex occurs in the $to-error string then simple, otherwise find the last string in 
			which it does occur from $lines-to-test. -->
		<xsl:choose>
			<xsl:when test="matches($to-error, $matching-regex)">
				
				<xsl:sequence select="
					(
						$preceding-lines, 
						concat(cfn:build-marked-string($to-error, $matching-regex, $error-message), $after-error),
						$trailing-lines
					)"/>
			</xsl:when>
			<xsl:when test="$row-num gt 1">
				<xsl:sequence select="cfn:insert-marker($row-num - 1, string-length($document-lines[$row-num -1]), $element-name, $error-message, $document-lines)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">Failed to find <xsl:value-of select="$matching-regex"/> in content.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
		 
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Generate a regular expression that matches the last occurence of the
			start of an element in a string.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:last-element-regex" as="xs:string">
		<xsl:param name="element-name" as="xs:string"/>

		<!-- match last occurrence of the above: -->
		<xsl:value-of select="concat('^(.*&lt;[\w:]*', $element-name, ')(/|>|\s+)(.*)$')"/>
		
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Given a string that matches our regex, split on that and insert marker</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:build-marked-string" as="xs:string">
		<xsl:param name="search-string" as="xs:string"/>
		<xsl:param name="regex" as="xs:string"/>
		<xsl:param name="message" as="xs:string"/>
		 
		
		<xsl:analyze-string select="$search-string" regex="{$regex}">
			<xsl:matching-substring>				
				<xsl:value-of select="concat(regex-group(1), ' __validation_marker=&quot;1&quot; ' , regex-group(2), regex-group(3))"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
		
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Given a node from a document, generate an XPath for that
			node. This is a modified version of the template used in the 
			Schematron skeleton files (see <xd:a href="http://www.schematron.com/">www.schematron.com/</xd:a></xd:p>
		</xd:desc>
	</xd:doc>	
	<xsl:template match="*" mode="get-full-xpath">
		<xsl:apply-templates select="parent::*" mode="get-full-xpath"/>
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="namespace-uri()=''">
				<xsl:value-of select="name()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*:</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>[namespace-uri()='</xsl:text>
				<xsl:value-of select="namespace-uri()"/>
				<xsl:text>']</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="preceding"
			select="count(preceding-sibling::*[local-name()=local-name(current()) and namespace-uri() = namespace-uri(current())])"/>
		<xsl:text>[</xsl:text>
		<xsl:value-of select="1+ $preceding"/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>