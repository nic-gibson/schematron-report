<?xml version="1.0" encoding="UTF-8"?>

<!--
    XML to HTML Verbatim Formatter with Syntax Highlighting
    
    Version 2.0
   	Contributors: Nic Gibson
   	Copyright 2011, 2013 Corbas Consulting Ltd
	Contact: corbas@corbas.co.uk

   	Full rewrite of Oliver Becker's original code to modularise for reuseability 
   	and rewrite to XSLT 2.0. Code for handling the root element removed as the
   	purpose of the rewrite is to handle code snippets. Modularisation and extensive
   	uses of modes used to ensure that special purpose usages can be achieved
	through use of xsl:import.
   	
    
    Version 1.1
    Contributors: Doug Dicks, added auto-indent (parameter indent-elements)
                  for pretty-print

    Copyright 2002 Oliver Becker
    ob@obqo.de
 
    Licensed under the Apache License, Version 2.0 (the "License"); 
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software distributed
    under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
    CONDITIONS OF ANY KIND, either express or implied. See the License for the
    specific language governing permissions and limitations under the License.

    Alternatively, this software may be used under the terms of the 
    GNU Lesser General Public License (LGPL).
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:cfn="http://www.corbas.co.uk/ns/xsl/functions" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cfn xd">

	<xsl:output method="xhtml" omit-xml-declaration="yes" indent="no"/>

	<xd:doc>
		<xd:desc>
			<xd:p>Set this to true to indent each line by $indent-increment characters.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="indent-elements" select="false()" as="xs:boolean"/>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Set <xd:b>max-depth</xd:b> to override the depth to which this stylesheet
			will traverse the input document before replacing the child nodes of the current
			node with ellipses.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="max-depth" select="10000" as="xs:integer"/>
	
	<xd:doc>
		<xd:desc><xd:p>If <xd:b>limit-text</xd:b> is set to true then the number of words
		output as element text will be determined by the <xd:b>max-words</xd:b> parameter.</xd:p></xd:desc>
	</xd:doc>
	<xsl:param name="limit-text" select="true()" as="xs:boolean"/>

	<xd:doc>
		<xd:desc><xd:p>If set to true, <xd:b>suppress-ns-declarations-default</xd:b> causes all namespace
		declarations to be omitted from the output. This can be overridden by setting the
		<xd:b>suppress-ns-declarations</xd:b> parameter on the element template.</xd:p></xd:desc>
	</xd:doc>
	<xsl:param name="suppress-ns-declarations-default" select="false()" as="xs:boolean"/>
		
	<xd:doc>
		<xd:desc>
			<xd:p>Set a sequence of URIs in the <xd:b>suppressed-namespaces</xd:b> parameter in order
			to always skip declarations for those namespaces. This allows sample code to be placed
			in a namespace and output without one.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="suppressed-namespaces" select="()" as="xs:string*"/>
	
	<xd:doc>
		<xd:desc><xd:p>Setting <xd:b>replace-entities-default</xd:b> to true to leave entities
			in element text unescaped. This can be overridden by setting the
			<xd:b>replace-entities</xd:b> parameter on the element template.</xd:p></xd:desc>
	</xd:doc>
	<xsl:param name="replace-entities-default" select="true()" as="xs:boolean"/>

	<xd:doc>
		<xd:desc>
			<xd:p><xd:b>indent-char</xd:b> is used for tab expansions and indents. Defaults to an
				non-breaking space.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="indent-char" select="'&#xA0;'" as="xs:string"/>

	<xd:doc>
		<xd:desc>
			<xd:p>Number of indent characters to indent each level of hierarchy when indenting is
				enabled.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="indent-increment" select="3" as="xs:integer"/>

	<xd:doc>
		<xd:desc>
			<xd:p>Maximum level of indent before we indent no further.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="max-indent" select="20" as="xs:integer"/>

	<xd:doc>
		<xd:desc>
			<xd:p><xd:b>tab-width</xd:b> is used for tab expansions. Defines the number of spaces
				that will be used to replace a tab character. Defaults to <xd:b>4</xd:b>.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:param name="tab-width" select="4"/>
	
	<xd:doc>
		<xd:desc><xd:p>Override <xd:b>max-words</xd:b> to change the maximum number of words included
		in element text.</xd:p></xd:desc>
	</xd:doc>
	<xsl:param name="max-words" select="50" as="xs:integer"/>

	<!-- horizontal tab chaaracter -->
	<xsl:variable name="tab" select="'&#x9;'" as="xs:string"/>

	<!-- replicate indent-char tab-width times -->
	<xsl:variable name="tab-out" select="cfn:replicate($indent-char, $tab-width)" as="xs:string"/>

	<!--  used to find new lines -->
	<xsl:variable name="nl" select="'&#xA;'" as="xs:string"/>


	<xd:doc>
		<xd:desc><xd:p>The verbatim processor for element contant. In order to make this
		as flexible as possible each component (opening tag, content, close tag) is processed
		by applying templates to the same element in a different mode.</xd:p>
		<xd:p>The indent parameter can be used to override the initial indent level (it's a count
		of indent levels)</xd:p>
		<xd:p>Overriding the <xd:p>depth</xd:p> parameter limits the depth to which the 
		stylesheet will process child nodes before replacing them with ellipses.</xd:p>
			<xd:p>Change the <xd:p>suppress-ns-declarations</xd:p> parameter to override
		the declaration of namespaces (prefixes will be output as needed regardless).</xd:p>
		<xd:p>Control whether or not entities in text content are replaced using the
		<xd:b>replace-entities</xd:b> parameter.</xd:p></xd:desc>
	
	</xd:doc>
	<xsl:template match="*" mode="verbatim" as="item()*">

		<xsl:param name="indent" select="0" as="xs:integer"/>
		<xsl:param name="depth" select="$max-depth" as="xs:integer"/>
		<xsl:param name="suppress-ns-declarations" select="$suppress-ns-declarations-default" as="xs:boolean"/>
		<xsl:param name="replace-entities" select="$replace-entities-default" as="xs:boolean"/>

		<!-- output the start tag, namespaces and attributes -->
		<xsl:apply-templates select="." mode="verbatim-start">
			<xsl:with-param name="suppress-ns-declarations" select="$suppress-ns-declarations"/>
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>

		<!-- output the node content -->
		<xsl:apply-templates select="." mode="verbatim-content">
			<xsl:with-param name="indent" select="$indent"/>
			<xsl:with-param name="depth" select="$depth"/>
			<xsl:with-param name="replace-entities" select="$replace-entities"/>
			<xsl:with-param name="suppress-ns-declarations" select="$suppress-ns-declarations"/>
		</xsl:apply-templates>

		<!-- output the closing tag-->
		<xsl:apply-templates select="." mode="verbatim-end">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>

		<!-- if  the root node, output a break. --> 
		<xsl:if test="not(parent::*)">
			<br/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>

	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>This template handles processing the start tag, namespaces and
		attributes.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*" mode="verbatim-start" as="item()*">
		<xsl:param name="indent" select="0" as="xs:integer"/>
		<xsl:param name="suppress-ns-declarations" select="$suppress-ns-declarations-default" as="xs:boolean"/>

		<!-- generate the indent if required -->
		<xsl:if test="$indent-elements">
			<br/>
			<xsl:value-of select="cfn:indent($indent)"/>
		</xsl:if>

		<!-- start tag -->
		<xsl:text>&lt;</xsl:text>
		
		<!-- prefix if required -->
		<xsl:apply-templates select="." mode="verbatim-ns-prefix"/>
		
		<!-- element name -->
		<xsl:apply-templates select="." mode="verbatim-element-name"/>
		
		<!-- any new namespace declarations unless suppressed -->
		<xsl:if test="$suppress-ns-declarations = false()">
			<xsl:apply-templates select="." mode="verbatim-ns-declarations"/>
		</xsl:if>
		
		<!-- attributes -->
		<xsl:apply-templates select="@*" mode="verbatim-attributes"/>

		<!-- if we have children -->
		<xsl:if test="node()">
			<xsl:text>&gt;</xsl:text>
		</xsl:if>

	</xsl:template>


	<xd:doc>
		<xd:desc><xd:p>Output the close for an element with no children.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*[not(node())]" mode="verbatim-end">
		<xsl:text> /&gt;</xsl:text>
	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>Output the closing tag for elements which have children.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*[node()]" mode="verbatim-end">

		<xsl:param name="indent" select="0"/>

		<!-- indent if we are indenting and we have element children -->
		<xsl:if test="* and $indent-elements">
			<br/>
			<xsl:value-of select="cfn:indent($indent)"/>
		</xsl:if>

		<!-- output closing tag with prefix if required -->
		<xsl:text>&lt;/</xsl:text>
		<xsl:apply-templates select="." mode="verbatim-ns-prefix"/>
		<xsl:apply-templates select="." mode="verbatim-element-name"/>
		<xsl:text>&gt;</xsl:text>

	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>Output the namespace prefix for an element that
		actually has one.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*[not(local-name() = name())]" mode="verbatim-ns-prefix">
		<xsl:variable name="ns" select="cfn:namespace-prefix(.)"/>
		<span class="verbatim-element-nsprefix">
			<xsl:value-of select="cfn:namespace-prefix(.)"/>
		</span>
		<xsl:text>:</xsl:text>
	</xsl:template>

	
	<xd:doc>
		<xd:desc><xd:p>Suppress processing of namespace prefix for elements in the
		default (or no) namespace.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*" mode="verbatim-ns-prefix"/>

	
	<xd:doc>
		<xd:desc><xd:p>Output the element name itself</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*" mode="verbatim-element-name">
		<span class="verbatim-element-name"><xsl:value-of select="local-name()"/></span>
	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>Output the namespace declarations required for an
		element. This will be any namespaces which just came into scope.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*" mode="verbatim-ns-declarations">
		<xsl:variable name="node" select="."/>
		
		<!-- get all prefixes which were declared on this node -->
		<xsl:variable name="namespace-prefixes" select="cfn:newly-declared-namespaces(.)"
			as="xs:string*"/>

		<!-- loop over them -->
		<xsl:for-each select="$namespace-prefixes">

			<!-- get the namespace uri -->
			<xsl:variable name="uri" select="namespace-uri-for-prefix(., $node)"/>

			<!-- output if not in our suppressed list -->
			<xsl:if test="not($uri = $suppressed-namespaces)">
				<span class="verbatim-ns-name">
					<xsl:value-of
						select="concat(' xmlns', if (. = '') then '' else concat(':', .), '=&quot;', $uri, '&quot;')"
					/>
				</span>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Generate a namespace declaration for those elements where the parent
		is in a namespace but the current node isn't</xd:desc>
	</xd:doc>
	<xsl:template match="*[not(namespace-uri())][namespace-uri(parent::*)]" mode="verbatim-ns-declarations">
		<span class="verbatim-ns-name"><xsl:text> xmlns=""</xsl:text></span>
	</xsl:template>
	
	<xd:doc>
		<xd:desc><xd:p>Process the content of elements. If depth has been exceeded,
		this template will replace the content of the current element with
		ellipsis. This template processes elements with children.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*[node()]" mode="verbatim-content">

		<xsl:param name="depth" as="xs:integer"/>
		<xsl:param name="indent" as="xs:integer"/>
		<xsl:param name="replace-entities" as="xs:boolean"/>
		<xsl:param name="suppress-ns-declarations" as="xs:boolean"/>

		<!-- process content and recurse if depth is positive -->
		<xsl:choose>

			<xsl:when test="$depth gt 0">
				<xsl:apply-templates mode="verbatim">
					<xsl:with-param name="indent" select="$indent + 1"/>
					<xsl:with-param name="depth" select="$depth - 1"/>
					<xsl:with-param name="replace-entities" select="$replace-entities"/>
					<xsl:with-param name="suppress-ns-declarations"
						select="$suppress-ns-declarations"/>
				</xsl:apply-templates>

			</xsl:when>

			<!-- replace children with ellipsis -->
			<xsl:otherwise>
				<xsl:text> … </xsl:text>
			</xsl:otherwise>

		</xsl:choose>


	</xsl:template>


	<xd:doc>
		<xd:desc><xd:p>Suppress process of the content of elements
		which have none.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="*[not(node())]" mode="verbatim-content"/>


	<xd:doc>
		<xd:desc><xd:p>Process attributes. Each attribute is output
		with a space before it. </xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="@*" mode="verbatim-attributes">
		
		<!-- space -->
		<xsl:text> </xsl:text>
		
		<!-- attribute name -->
		<span class="verbatim-attr-name"><xsl:value-of select="name()"/></span>
		
		<!-- equals and start of value -->
		<xsl:text>=&quot;</xsl:text>
		
		<!-- value with entities escaped -->
		<span class="verbatim-attr-content">
			<xsl:value-of select="cfn:html-replace-entities(normalize-space(.), true())"/>
		</span>
		
		<!-- end quote -->
		<xsl:text>&quot;</xsl:text>
	</xsl:template>


	<xd:doc>
		<xd:desc><xd:p>Process text. Potentially
		replaces entities and restricts the amount of output text. Newlines
		are replaced with breaks.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="text()" mode="verbatim">

		<xsl:param name="replace-entities"/>

		<span class="verbatim-text">
			<xsl:call-template name="preformatted-output">
				<xsl:with-param name="text"
					select="if ($replace-entities = true()) 
						then 
							if ($limit-text = true()) 
								then cfn:html-replace-entities(cfn:limit-text(.))
								else cfn:html-replace-entities(.)
						else
							if ($limit-text = true()) 
								then cfn:limit-text(.)
								else .
						"
				/>
			</xsl:call-template>
		</span>

	</xsl:template>


	<xd:doc>
		<xd:desc><xd:p>Process comments. NOTE: this will always place
		a newline before the comment. Sometimes this may not give optimal output
		but it's hard to see how to resolve it. The problem occurs when the comment
		is separated from the node before by spaces or tabs not a newline.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="comment()" mode="verbatim">

		<xsl:param name="indent" select="0"/>

		<!-- indent if required -->
		<xsl:if test="$indent-elements">
			<br/>
			<xsl:value-of select="cfn:indent($indent)"/>
		</xsl:if>

		<!-- output the comment -->
		<xsl:text>&lt;!--</xsl:text>
		<span class="verbatim-comment">
			<xsl:call-template name="preformatted-output">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>
		</span>
		<xsl:text>--&gt;</xsl:text>
		<xsl:if test="parent::*">
			<br/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>Output processing instructions.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template match="processing-instruction()" mode="verbatim">
		<xsl:text>&lt;?</xsl:text>
		<span class="verbatim-pi-name">
			<xsl:value-of select="name()"/>
		</span>
		<xsl:if test=".!=''">
			<xsl:text> </xsl:text>
			<span class="verbatim-pi-content">
				<xsl:value-of select="."/>
			</span>
		</xsl:if>
		<xsl:text>?&gt;</xsl:text>
		<xsl:if test="not(parent::*)">
			<br/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>This template replaces all tabs with the tab indent (defined
		as $tab-width indent characters). </xd:p></xd:desc>
	</xd:doc>
	<!-- preformatted output: space as &nbsp;, tab as 8 &nbsp;
                             nl as <br> -->
	<xsl:template name="preformatted-output">
		<xsl:param name="text"/>
		<xsl:call-template name="output-nl">
			<xsl:with-param name="text" select="replace($text, $tab, $tab-out)"
			/>
		</xsl:call-template>
	</xsl:template>

	<xd:doc>
		<xd:desc><xd:p>This template replaces all occurrences of newline in the input text with
		a break element. This is implemented as template rather than a function as it generaters
		output.</xd:p></xd:desc>
	</xd:doc>
	<xsl:template name="output-nl">
		<xsl:param name="text"/>
		<xsl:variable name="tokens" select="tokenize($text, '&#xA;')"/>
		<xsl:choose>
			<xsl:when test="count($tokens) = 1">
				<xsl:value-of select="$tokens"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$tokens">
					<br/>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xd:doc>
		<xd:desc>
			<xd:p>Restrict text where we have more than $max-words words to first five, ellipsis and last
				five. </xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:limit-text">
		<xsl:param name="text"/>
		<xsl:variable name="words" select="tokenize($text, '\s+')" as="xs:string*"/>
		<xsl:variable name="nwords" select="count($words)" as="xs:integer"/>
		<xsl:value-of
			select="if ($nwords lt 50) 
   			then $words else 
   			string-join((
   				for $n in 1 to 5 return $words[$n], 
   				' … ', 
   				for $n in $nwords - 5 to $nwords return $words[$n]), 
   				' ')"
		/>
	</xsl:function>


	<xd:doc>
		<xd:desc>
			<xd:p>This function replaces all occurrences of ampersand, less than and greater than,
				with entities. If the <xd:i>with-attrs</xd:i> parameter is set then the value is
				assumed to in an attribute and quotes are replaced as well. </xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:html-replace-entities">
		<xsl:param name="value"/>
		<xsl:param name="with-attrs"/>
		<xsl:variable name="tmp"
			select="
			replace(replace(replace($value, '&amp;', '&amp;amp;'),'&lt;', '&amp;lt;'),'&gt;', '&amp;gt;')"/>
		<xsl:value-of
			select="if ($with-attrs) then replace(replace($tmp, '&quot;', '&amp;quot;'), '&#xA;', '&amp;#xA;') else $tmp"
		/>
	</xsl:function>

	<xd:doc>
		<xd:desc><xd:p>Defaulted version of above which never replaces in attributes.</xd:p></xd:desc>
	</xd:doc>
	<xsl:function name="cfn:html-replace-entities" as="xs:string">
		<xsl:param name="value"/>
		<xsl:sequence select="cfn:html-replace-entities($value, false())"/>
	</xsl:function>

	<xd:doc>
		<xd:desc>
			<xd:p>Return the namespace prefix for a node if known and it has one.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:namespace-prefix" as="xs:string">

		<xsl:param name="node" as="element()"/>
		<xsl:variable name="uri" select="namespace-uri($node)" as="xs:anyURI"/>
		<xsl:variable name="prefixes" select="in-scope-prefixes($node)" as="xs:string*"/>		
		<xsl:variable name="prefixes" select="if (exists($uri) ) 
			then for $ns in $prefixes 
				 return 
					(if (namespace-uri-for-prefix($ns, $node) = $uri) then $ns else ())
			else ()"/>
		
		<xsl:sequence select="$prefixes[1]"/>

	</xsl:function>

	<xd:doc>
		<xd:desc>
			<xd:p>Return a sequence of namespace prefixes which were not declared on the parent
				element.Gets the in scope namespace URIs for the parameter element and the parent
				element. Builds a list of those namespaces that are not in the parent scope. Then
				filters the current prefix list based on that result to find the new prefixes
				only</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:newly-declared-namespaces" as="xs:string*">
		<xsl:param name="node" as="element()"/>
		<xsl:variable name="parent-node" select="$node/parent::*"/>

		<!-- in scope namespace uris for this node -->
		<xsl:variable name="our-namespaces"
			select="for $ns in in-scope-prefixes($node) return namespace-uri-for-prefix($ns, $node)"/>

		<!-- in scope namespace uris for the parent node -->
		<xsl:variable name="parent-namespaces"
			select="if ($parent-node) then for $ns in in-scope-prefixes($parent-node) return namespace-uri-for-prefix($ns, $parent-node) else ()"/>

		<!-- the URIs that have just become in scope -->
		<xsl:variable name="new-namespace-uris"
			select="$our-namespaces[not(. = $parent-namespaces)]"/>

		<!-- Filter the in scope prefixes based on whether their URIs are represented in the new list -->
		<xsl:variable name="new-namespaces"
			select="for $prefix in in-scope-prefixes($node) return if (namespace-uri-for-prefix($prefix, $node) = $new-namespace-uris) then $prefix else ()"/>

		<!--    Debug output
		<xsl:message>Our Namespaces (<xsl:value-of select="string-join($our-namespaces, ', ')"/>)</xsl:message>
		<xsl:message>Parent Namespaces (<xsl:value-of select="string-join($parent-namespaces, ', ')"/>)</xsl:message>		
		<xsl:message>New Namespaces (<xsl:value-of select="string-join($new-namespace-uris, ', ')"/>)</xsl:message>
		-->

		<!-- Return the sequence or prefixes, having stripped out the xml namespace -->
		<xsl:sequence select="$new-namespaces[not(. = 'xml')]"/>

	</xsl:function>



	<xd:doc>
		<xd:desc>
			<xd:p>Return true() if a node is in the default namespace. Checks by ensuring that the
				element is in a namespace and then checking if the namespace prefix is blank.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:in-default-ns" as="xs:boolean">
		<xsl:param name="node" as="element()"/>
		<xsl:variable name="prefix" select="cfn:namespace-prefix($node)"/>
		<xsl:value-of select="if (namespace-uri($node) and $prefix = '') then true() else false()"/>
	</xsl:function>

	<xd:doc>
		<xd:desc>
			<xd:p>Return a string replicated a given number of times.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:function name="cfn:replicate" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:param name="count" as="xs:integer"/>
		<xsl:value-of
			select="if ($count = 0) then '' else string-join((for $n in 1 to $count return $input), '')"
		/>
	</xsl:function>

	<xd:doc>
		<xd:desc>
			<xd:p>Create the indent string to be used at any particular point in the processing.
				Never creates an indent string longer than that defined by max-increment.</xd:p>
		</xd:desc>
	</xd:doc>

	<xsl:function name="cfn:indent" as="xs:string">
		<xsl:param name="base-indent" as="xs:integer"/>
		<xsl:variable name="indent"
			select="if ($base-indent gt $max-indent) then $max-indent else $base-indent"/>

		<xsl:value-of select="cfn:replicate($indent-char, $indent * $indent-increment)"/>
	</xsl:function>

</xsl:stylesheet>
