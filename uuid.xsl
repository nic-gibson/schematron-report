<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:exsl-random="http://exslt.org/random" xmlns:cfn="http://www.corbas.co.uk/ns/xsl/functions"
	exclude-result-prefixes="xs xd" version="2.0">
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Oct 18, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
			<xd:p>Generate v4 GUIDs using Saxon</xd:p>
		</xd:desc>
	</xd:doc>
	
	<!-- Override this to change the number of GUIDs that can be generated. Note that
	Saxon generates numbers on demand so setting a high number is not a bad thing. -->
	<xsl:param name="uuid-count" select="10000"/>
	

	<!-- Short hands for various powers of two -->
	<xsl:variable name="two-fourteen" as="xs:integer" select="256 * 64"/>
	<xsl:variable name="two-twelve" as="xs:integer" select="256 * 16"/>
	<xsl:variable name="two-sixteen" as="xs:integer" select="256 * 256"/>
	<xsl:variable name="two-thirty-two" as="xs:integer" select="$two-sixteen * $two-sixteen"/>
	<xsl:variable name="two-forty-eight" as="xs:integer" select="$two-sixteen * $two-thirty-two"/>

	<!-- We take five random numbers and multiply them by these to get the portions of the GUID. -->
	<xsl:variable name="multipliers"
		select="($two-thirty-two, $two-sixteen, $two-twelve, $two-fourteen, $two-forty-eight)"/>
	
	<!-- Adding these numbers to the numbers derived above sets the required bits -->
	<xsl:variable name="additives" select="(0, 0, 16384,  32768, 0)"/>


	<!-- Generate enough numbers for $uuid-count UUIDs -->
	<xsl:variable name="random-source"
		select="exsl-random:random-sequence($uuid-count * count($multipliers), seconds-from-dateTime(current-dateTime()))"/>


	<xd:doc>
		<xd:desc>
			<xd:p>Generates a version 4 UUID (see RFC4122 -  <xd:a href="http://tools.ietf.org/html/rfc4122#page-14">http://tools.ietf.org/html/rfc4122#page-14</xd:a></xd:p>
			<xd:p>A sequence number is required as an input in order to get useful values from the pseudo-random sequence used to prime the generator. For any given run
			of the script, the same sequence number will return the same UUID.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:get-uuid" as="xs:string">
		<xsl:param name="seq-num" as="xs:integer"/>
		
		<!-- get the starting point in the sequence -->
		<xsl:variable name="base" select="($seq-num - 1) * count($multipliers) + 1" as="xs:integer"/>
		
		<!-- multiply a random number by each multiplier, convert down to an integer and then add any additive value -->
		<xsl:variable name="multiplied" select="for $x in (0 to count($multipliers) - 1) return xs:integer(floor($random-source[$base + $x] * $multipliers[$x + 1])) + $additives[$x + 1]"/>
		
		<!-- convert the values to hex -->
		<xsl:variable name="hex-data"
			select="for $x in $multiplied return cfn:padded-int-to-hex($x)"
			as="xs:string*"/>
		
		<!-- join them with a hyphen -->
		<xsl:sequence select="string-join($hex-data, '-')"/>
	</xsl:function>


	<!-- puts a leading zero on any hex number with an odd number of characters as cfn:int-to-hex will not -->
	<xsl:function name="cfn:padded-int-to-hex" as="xs:string">
		<xsl:param name="in" as="xs:integer"/>
		<xsl:variable name="hex" as="xs:string" select="cfn:int-to-hex($in)"/>
		<xsl:sequence select="if (string-length($hex) mod 2) then concat('0', $hex) else $hex"/>
	</xsl:function>

	<xsl:function name="cfn:int-to-hex" as="xs:string">
		<xsl:param name="in" as="xs:integer"/>
		<xsl:sequence
			select="
			if ($in eq 0) then '0' 
			else concat(
				if ($in gt 16) then 
					cfn:int-to-hex($in idiv 16) else '',
					substring('0123456789abcdef', 
						($in mod 16) +1, 1))"
		/>
	</xsl:function>


</xsl:stylesheet>
