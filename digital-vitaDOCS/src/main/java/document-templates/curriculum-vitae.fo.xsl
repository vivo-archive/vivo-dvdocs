<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="fo">
    
	<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>
	<xsl:param name="citationFormat" select="'apa'"/>
	<xsl:param name="documentFontType" select="'Times'"/>
	<xsl:param name="documentFontSize" select="'12pt'"/>
	<xsl:param name="from" select="'vivo'"/>
	<xsl:param name="targetFormat" select="'pdf'"/>
	<xsl:param name="currentDate" select="'vivo'"/>
	
	<xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<xsl:variable name="ci_positions">
		<xsl:for-each select="//personsProfessionalPositions[endYear/presentYear='true']">
			<xsl:value-of select="translate(title,$uc,$lc)"/>; 
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="isProfessor">
		<xsl:call-template name="_testProfessorship">
			<xsl:with-param name="titles" select="$ci_positions"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="isAssociateProfessor">
		<xsl:call-template name="_testAssociateProfessorship">
			<xsl:with-param name="titles" select="$ci_positions"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="isAssistantProfessor">
		<xsl:call-template name="_testAssistantProfessorship">
			<xsl:with-param name="titles" select="$ci_positions"/>
		</xsl:call-template>
	</xsl:variable>
 
	<xsl:template name="EmitTitle">
		<xsl:param name="title"/>
		<xsl:if test="string-length($title) &gt; 0">
			<xsl:variable name="lastChar"
				select="substring(normalize-space($title), string-length(normalize-space($title)), 1)"/>
			<xsl:value-of select="normalize-space($title)"/>
			<xsl:if test="($lastChar != '!') and ($lastChar != '?') and ($lastChar != '.')">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<!--
			ConvertSciToNumString 
			By: 	Michael Case
			University of California, Davis
			case@xxxxxxxxxxxxxxxxxx
			
			
			Converts a string from Scientific notation to an XML acceptable number
			(as a string).
			e.g. convert from 1E-10 to 0.0000000001
			
			Include this template in your XSL file using: <xsl:include
			href="ConvertSciToNumString.xsl">
			
			Input parameters to ConvertSciToNumString
			myval		the number to be checked.
			
			Input parameters to realConvertSciToNumString (base 10 assumed):
			vnum		the un-signed mantissa
			sgn		the sign, an empty string or '-'
			
			This puts out a text result which can be enclosed in the calling XSL
			with <xsl:element>,
			<xsl:attribute> or nothing (leave as text). 
		-->

	<!-- necessary global maximum/minimum of exponent 'stuffer', set to 100
		-->
	<xsl:variable name="max-exp">
		<xsl:value-of select="'0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'"/>
	</xsl:variable>

	<xsl:template name="convertSciToNumString">
		<xsl:param name="myval" select="''"/>
		<xsl:variable name="useval">
			<xsl:value-of select="translate(string($myval),'e','E')"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(number($useval))">
				<xsl:choose>
					<xsl:when test="number(substring-before($useval, 'E'))">
						<xsl:choose>
							<xsl:when test="number(substring-after($useval, 'E'))">
								<xsl:if test="number(substring-before($useval, 'E')) &lt; 0">
									<xsl:call-template name="realConvertSciToNumString">
										<xsl:with-param name="vnum"
											select="substring-after($useval, '-')"/>
										<xsl:with-param name="vsgn" select="'-'"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="number(substring-before($useval, 'E')) &gt; 0">
									<xsl:call-template name="realConvertSciToNumString">
										<xsl:with-param name="vnum" select="$useval"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$useval"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$useval"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($useval)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="realConvertSciToNumString">
		<xsl:param name="vnum" select="0"/>
		<xsl:param name="vsgn" select="''"/>
		<xsl:choose>
			<xsl:when test="number(vnum)">
				<xsl:value-of select="$vnum"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="vmantisa">
					<xsl:value-of select="number(substring-before($vnum,
							'E'))"/>
				</xsl:variable>
				<xsl:variable name="vexponent">
					<xsl:value-of select="number(substring-after($vnum,
							'E'))"/>
				</xsl:variable>

				<!--  handle 0.9.... -->
				<xsl:if test="$vmantisa &lt; 1">

					<!-- handle 0.9E-9 -->
					<xsl:if test="$vexponent &lt; 0">
						<xsl:variable name="voffset">
							<xsl:value-of select="string-length(substring-before($vmantisa, '.'))"/>
						</xsl:variable>
						<xsl:value-of
							select="concat($vsgn, '0', '.',
								substring($max-exp, 1, ($vexponent * -1) -
								$voffset),substring-before($vmantisa,'.'), substring-after($vmantisa,
								'.'))"
						/>
					</xsl:if>

					<!-- handle 0.9E9 -->
					<xsl:if test="$vexponent &gt; 0">
						<xsl:variable name="voffset">
							<xsl:value-of select="string-length(substring-after($vmantisa, '.'))"/>
						</xsl:variable>

						<xsl:choose>
							<!-- handle .932E1 -->
							<xsl:when test="$voffset &gt; $vexponent">
								<xsl:value-of
									select="concat($vsgn,
										substring(substring-after($vmantisa, '.'), 1, $vexponent), '.',
										substring(substring-after($vmantisa, '.'), $vexponent + 1,
										string-length($vmantisa) - $vexponent))"
								/>
							</xsl:when>

							<!-- handle .9E3 -->
							<xsl:when test="$voffset &lt; $vexponent">
								<xsl:value-of
									select="concat($vsgn,
										substring-after($vmantisa, '.'), substring($max-exp, 1, ($vexponent -
										$voffset)))"
								/>
							</xsl:when>

							<!-- handle .9E1 -->
							<xsl:when test="$voffset = $vexponent">
								<xsl:value-of
									select="concat($vsgn,
										substring-before($vmantisa, '.'), substring-after($vmantisa, '.'))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="NaN"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>

				<!-- handle 9.9.... -->
				<xsl:if test="$vmantisa &gt;= 1">

					<!-- handle 9.9E-9 -->
					<xsl:if test="$vexponent &lt; 0">
						<xsl:variable name="voffset">
							<xsl:value-of select="string-length(substring-before($vmantisa, '.'))"/>
						</xsl:variable>
						<xsl:choose>

							<!-- really handle 923.9E-1 -->
							<xsl:when test="$voffset &gt; $vexponent * -1">
								<xsl:value-of
									select="concat($vsgn,
										substring(substring-before($vmantisa, '.'), 1,
										string-length(substring-before($vmantisa, '.')) + $vexponent), '.',
										substring(substring-before($vmantisa, '.'),
										string-length(substring-before($vmantisa, '.')) + $vexponent + 1,
										$vexponent * -1), substring-after($vmantisa, '.'))"
								/>
							</xsl:when>

							<!-- really handle 9.9E-9 -->
							<xsl:when
								test="$voffset &lt; $vexponent * -1 and
									$voffset &gt; 0">
								<xsl:value-of
									select="concat($vsgn, '0', '.',
										substring($max-exp, 1, ($vexponent * -1) - $voffset),
										substring-before($vmantisa, '.'), substring-after($vmantisa, '.'))"
								/>
							</xsl:when>

							<!-- handle 9.9E-1 -->
							<xsl:when
								test="$voffset = $vexponent * -1 and
									$voffset &gt; 0">
								<xsl:value-of
									select="concat($vsgn, '0', '.',
										substring-before($vmantisa, '.'), substring-after($vmantisa, '.'))"
								/>
							</xsl:when>

							<!-- handle 9E-9 -->
							<xsl:when
								test="$voffset = 0 and
									string-length($vmantisa) &lt; $vexponent * -1">
								<xsl:value-of
									select="concat($vsgn, '0', '.',
										substring($max-exp, 1, ($vexponent * -1) - string-length($vmantisa)),
										$vmantisa)"
								/>
							</xsl:when>

							<!-- handle 999E-1-->
							<xsl:when
								test="$voffset = 0 and
									string-length($vmantisa) &gt; $vexponent * -1">
								<xsl:value-of
									select="concat($vsgn,
										substring($vmantisa, 1, string-length($vmantisa) + $vexponent), '.',
										substring($vmantisa, string-length($vmantisa) + $vexponent + 1,
										$vexponent * -1))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'NaN'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>

					<!-- handle 9.9E9 -->
					<xsl:if test="$vexponent &gt; 0">
						<xsl:variable name="voffset">
							<xsl:value-of select="string-length(substring-after($vmantisa, '.'))"/>
						</xsl:variable>
						<xsl:value-of
							select="concat($vsgn,
								substring-before($vmantisa, '.'), substring-after($vmantisa, '.'),
								substring($max-exp, 1, ($vexponent - 1 - $voffset)))"
						/>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:attribute-set name="table">
		<xsl:attribute name="border-collapse">separate</xsl:attribute>
		<xsl:attribute name="border-separation.inline-progression-direction">8pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="h1">
		<xsl:attribute name="text-transform">uppercase</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-family"><xsl:value-of select="$documentFontType"/></xsl:attribute>
		<xsl:attribute name="font-size">14pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="h2">
		<xsl:attribute name="text-transform">none</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-family"><xsl:value-of select="$documentFontType"/></xsl:attribute>
		<xsl:attribute name="font-size">12pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template name="CitePageVolumeIssue">
		<xsl:choose>
			<xsl:when test="volume &gt; 0">
				<xsl:value-of select="normalize-space(volume)"/>
				<xsl:if test="issue &gt; 0">
					(<xsl:value-of select="normalize-space(issue)"/>)</xsl:if>
				<xsl:if test="string-length(pages) &gt; 0">
					<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(pages)"/>	
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length(pages) &gt; 0">
					<xsl:value-of select="normalize-space(pages)"/>	
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="EmitExternalService">
		<xsl:call-template name="EmitExternalServiceList">
			<xsl:with-param name="cType" select="'PublicPolicyPrograms'"/>
			<xsl:with-param name="sectionTitle" select="'Public Policy and Programs'"/>
		</xsl:call-template>
		<xsl:call-template name="EmitExternalServiceList">
			<xsl:with-param name="cType" select="'ProfessionalPractice'"/>
			<xsl:with-param name="sectionTitle" select="'Professional Practice'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="EmitExternalServiceList">
		<xsl:param name="cType"/>
		<xsl:param name="sectionTitle"/>
		<xsl:choose>
			<xsl:when test="$cType = 'PublicPolicyPrograms'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='publicpolicyprograms']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-after.optimum="1em" space-before.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitExternalServiceInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$cType = 'ProfessionalPractice'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='professionalpractice']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-after.optimum="1em" space-before.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitExternalServiceInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="EmitExternalServiceInfo">
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="emitVitaDateRange">
						<xsl:with-param name="startDate" select="dateRange/startDate"/>
						<xsl:with-param name="endDate" select="dateRange/endDate"/>
						<xsl:with-param name="ignorePresent" select="'false'"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="implode">
						<xsl:with-param name="values" select="role | organization | description"/>
						<xsl:with-param name="format" select="'role,organization,description'"/>
						<xsl:with-param name="delimiter" select="', '"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="EmitCommittees">
		<xsl:call-template name="EmitCommitteeList">
			<xsl:with-param name="cType" select="'Department'"/>
			<xsl:with-param name="sectionTitle" select="'Department Committees'"/>
		</xsl:call-template>

		<xsl:call-template name="EmitCommitteeList">
			<xsl:with-param name="cType" select="'School/University'"/>
			<xsl:with-param name="sectionTitle" select="'School/University Committees'"/>
		</xsl:call-template>
		
		<xsl:call-template name="EmitCommitteeList">
			<xsl:with-param name="cType" select="'UPMC/UPP/VA'"/>
			<xsl:with-param name="sectionTitle" select="'UPMC/UPP/VA Committees'"/>
		</xsl:call-template>
		
	   <xsl:call-template name="EmitCommitteeList">
			<xsl:with-param name="cType" select="'ExternalOrganizations'"/>
			<xsl:with-param name="sectionTitle" select="'External Organizations'"/>
		</xsl:call-template>

		<xsl:call-template name="EmitCommitteeList">
			<xsl:with-param name="cType" select="'Other'"/>
			<xsl:with-param name="sectionTitle" select="'Other Committees'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="EmitCommitteeList">
		<xsl:param name="cType"/>
		<xsl:param name="sectionTitle"/>
		<xsl:choose>
			<xsl:when test="$cType = 'Department'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='committeemembership' and translate(committeeType,$uc,$lc)='department']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-after.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitCommitteeInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$cType = 'School/University'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='committeemembership' and ((translate(committeeType,$uc,$lc)='school') or (translate(committeeType,$uc,$lc)='university'))]"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitCommitteeInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
			
			<xsl:when test="$cType = 'UPMC/UPP/VA'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='committeemembership' and translate(committeeType,$uc,$lc)='upmc/upp/va']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitCommitteeInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$cType = 'ExternalOrganizations'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='committeemembership' and translate(committeeType,$uc,$lc)='externalorganizations']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="emitVitaDateRange">
												<xsl:with-param name="startDate" select="dateRange/startDate"/>
												<xsl:with-param name="endDate" select="dateRange/endDate"/>
												<xsl:with-param name="ignorePresent" select="'false'"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="implode">
												<xsl:with-param name="values" select="role | organization"/>
												<xsl:with-param name="format" select="'role,organization'"/>
												<xsl:with-param name="delimiter" select="', '"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>


			<xsl:when test="$cType = 'Other'">
				<xsl:variable name="data"
					select="personsActivities[translate(@xsi:type,$uc,$lc)='committeemembership' and translate(committeeType,$uc,$lc)='other']"/>
				<xsl:if test="count($data) &gt; 0">
					<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">
						<xsl:value-of select="$sectionTitle"/>
					</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5.0in"/>
						<fo:table-body>
							<xsl:for-each select="$data">
								<xsl:call-template name="EmitCommitteeInfo"/>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="MonthAsMMM">
		<xsl:param name="monthNumber"/>
		<xsl:choose>
			<xsl:when test="$monthNumber=1">Jan</xsl:when>
			<xsl:when test="$monthNumber=2">Feb</xsl:when>
			<xsl:when test="$monthNumber=3">Mar</xsl:when>
			<xsl:when test="$monthNumber=4">Apr</xsl:when>
			<xsl:when test="$monthNumber=5">May</xsl:when>
			<xsl:when test="$monthNumber=6">Jun</xsl:when>
			<xsl:when test="$monthNumber=7">Jul</xsl:when>
			<xsl:when test="$monthNumber=8">Aug</xsl:when>
			<xsl:when test="$monthNumber=9">Sep</xsl:when>
			<xsl:when test="$monthNumber=10">Oct</xsl:when>
			<xsl:when test="$monthNumber=11">Nov</xsl:when>
			<xsl:when test="$monthNumber=12">Dec</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="MonthAsMMMM">
		<xsl:param name="monthNumber"/>
		<xsl:choose>
			<xsl:when test="$monthNumber=1">January</xsl:when>
			<xsl:when test="$monthNumber=2">February</xsl:when>
			<xsl:when test="$monthNumber=3">March</xsl:when>
			<xsl:when test="$monthNumber=4">April</xsl:when>
			<xsl:when test="$monthNumber=5">May</xsl:when>
			<xsl:when test="$monthNumber=6">June</xsl:when>
			<xsl:when test="$monthNumber=7">July</xsl:when>
			<xsl:when test="$monthNumber=8">August</xsl:when>
			<xsl:when test="$monthNumber=9">September</xsl:when>
			<xsl:when test="$monthNumber=10">October</xsl:when>
			<xsl:when test="$monthNumber=11">November</xsl:when>
			<xsl:when test="$monthNumber=12">December</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitStringWithDelimiter">
		<xsl:param name="inString"/>
		<xsl:param name="charList"/>
		<xsl:param name="delimeter"/>
		<xsl:variable name="nString" select="normalize-space($inString)"/>
		<xsl:if test="string-length($nString) &gt; 0">
			<xsl:variable name="lastChar" select="substring($nString, string-length($nString), 1)"/>
			<xsl:value-of select="$nString"/><xsl:if test="not(contains($charList, $lastChar))"><xsl:value-of select="delimeter"/></xsl:if><xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="emitAPACitationVitaDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>
		
		<xsl:choose>
			<xsl:when test="$startDate/month != 0">
				<xsl:choose>
					<xsl:when test="$endDate/month != 0">
						<xsl:choose>
							<xsl:when test="$endDate/month = $startDate/month">
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<!-- show the day(s) -->
										<xsl:value-of select="$startDate/day"/><xsl:if test="$endDate/day != 0"><xsl:if test="$endDate/day != $startDate/day"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/day"/></xsl:if></xsl:if><xsl:text> </xsl:text>
									</xsl:when>
								</xsl:choose>
								<!-- conference starts & ends in the same month -->
								<xsl:call-template name="MonthAsMMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template><xsl:text> </xsl:text>
								
								<xsl:value-of select="$startDate/year"/>
							</xsl:when>
							
							<xsl:otherwise>
								
								<!-- conference starts & ends in different months -->
								
								<!-- Starting day -->
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/>
									</xsl:when>
								</xsl:choose>
								<!-- Starting month -->
								<xsl:call-template name="MonthAsMMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template>
								
								<xsl:text>-</xsl:text>
								<xsl:if test="$endDate/day != 0">
									<xsl:text> </xsl:text><xsl:value-of select="$endDate/day"/>
								</xsl:if>
								<xsl:call-template name="MonthAsMMMM">
									<xsl:with-param name="monthNumber" select="$endDate/month"/>
								</xsl:call-template><xsl:text> </xsl:text>
								
								<xsl:value-of select="$startDate/year"/><xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- conference starts & ends in the same month; end month not specified -->
						<xsl:choose>
							<xsl:when test="$startDate/day != 0">
								<!-- show the day(s) -->
								<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/><xsl:if test="$endDate/day != 0"><xsl:if test="$endDate/day != $startDate/day"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/day"/></xsl:if></xsl:if><xsl:text> </xsl:text>
							</xsl:when>
						</xsl:choose>
						<xsl:call-template name="MonthAsMMMM">
							<xsl:with-param name="monthNumber" select="$startDate/month"/>
						</xsl:call-template><xsl:text> </xsl:text>
						
						<xsl:value-of select="$startDate/year"/><xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Start month not specified -->
				<xsl:if test="$startDate/year != 0">
					<xsl:value-of select="$startDate/year"/><xsl:if test="($endDate/year != $startDate/year) and ($endDate/year != 0)"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/year"/></xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="emitAPACitationVitaDate">
		<xsl:param name="vitaDate"/>
		<xsl:choose>
			<xsl:when test="$vitaDate/year != 0">
				<xsl:choose>
					<xsl:when test="$vitaDate/day != 0"><xsl:text> </xsl:text><xsl:value-of select="$vitaDate/day"/></xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$vitaDate/month != 0"><xsl:text> </xsl:text><xsl:call-template name="MonthAsMMMM">
						<xsl:with-param name="monthNumber" select="$vitaDate/month"/>
					</xsl:call-template><xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of select="$vitaDate/year"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="emitCitationVitaDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>

		<xsl:choose>
			<xsl:when test="$startDate/month != 0">
				<xsl:choose>
					<xsl:when test="$endDate/month != 0">
						<xsl:choose>
							<xsl:when test="$endDate/month = $startDate/month">
								<xsl:value-of select="$startDate/year"/>
								<xsl:text> </xsl:text>
								<!-- conference starts & ends in the same month -->
								<xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template>
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<!-- show the day(s) -->
										<xsl:text> </xsl:text>
										<xsl:value-of select="$startDate/day"/>
										<xsl:if test="$endDate/day != 0">
											<xsl:if test="$endDate/day != $startDate/day">
												<xsl:text>-</xsl:text>
												<xsl:value-of select="$endDate/day"/>
											</xsl:if>
										</xsl:if>
										<xsl:text> </xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>

							<xsl:otherwise>
								<xsl:value-of select="$startDate/year"/>
								<xsl:text> </xsl:text>
								<!-- conference starts & ends in different months -->
								<!-- Starting month -->
								<xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template>
								<!-- Starting day -->
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$startDate/day"/>
									</xsl:when>
								</xsl:choose>
								<xsl:text>-</xsl:text>
								<xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$endDate/month"/>
								</xsl:call-template>
								<xsl:if test="$endDate/day != 0">
									<xsl:text> </xsl:text>
									<xsl:value-of select="$endDate/day"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- conference starts & ends in the same month; end month not specified -->
						<xsl:value-of select="$startDate/year"/>
						<xsl:text> </xsl:text>
						<xsl:call-template name="MonthAsMMM">
							<xsl:with-param name="monthNumber" select="$startDate/month"/>
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="$startDate/day != 0">
								<!-- show the day(s) -->
								<xsl:text> </xsl:text>
								<xsl:value-of select="$startDate/day"/>
								<xsl:if test="$endDate/day != 0">
									<xsl:if test="$endDate/day != $startDate/day">
										<xsl:text>-</xsl:text>
										<xsl:value-of select="$endDate/day"/>
									</xsl:if>
								</xsl:if>
								<xsl:text> </xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Start month not specified -->
				<xsl:choose>
					<xsl:when test="$startDate/year != 0">
						<xsl:choose>
							<!-- start year and end year both exist -->
							<xsl:when test="$endDate/year = $startDate/year">
								<xsl:value-of select="$startDate/year"/>
								<xsl:if test="$endDate/month != 0">
									<xsl:text> </xsl:text>
									<xsl:call-template name="MonthAsMMM">
										<xsl:with-param name="monthNumber" select="$endDate/month"/>
									</xsl:call-template>
									<xsl:if test="$endDate/day != 0">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$endDate/day"/>
									</xsl:if>
								</xsl:if>
							</xsl:when>
							<!-- start year exist, end year may or may not exist -->
							<xsl:otherwise>
								<xsl:value-of select="$startDate/year"/>
								<xsl:if test="$endDate/year != 0">
									<xsl:text>-</xsl:text>
									<xsl:value-of select="$endDate/year"/>
									<xsl:if test="$endDate/month != 0">
										<xsl:text> </xsl:text>
										<xsl:call-template name="MonthAsMMM">
											<xsl:with-param name="monthNumber" select="$endDate/month"/>
										</xsl:call-template>
										<xsl:if test="$endDate/day != 0">
											<xsl:text> </xsl:text>
											<xsl:value-of select="$endDate/day"/>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$endDate/year != 0">
							<xsl:value-of select="$endDate/year"/>
							<xsl:if test="$endDate/month != 0">
									<xsl:text> </xsl:text>
									<xsl:call-template name="MonthAsMMM">
										<xsl:with-param name="monthNumber" select="$endDate/month"/>
									</xsl:call-template>
									<xsl:if test="$endDate/day != 0">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$endDate/day"/>
									</xsl:if>
								</xsl:if>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="emitCitationVitaDate">
		<xsl:param name="vitaDate"/>

		<xsl:choose>
			<xsl:when test="$vitaDate/year != 0">
				<xsl:value-of select="$vitaDate/year"/>
				<xsl:choose>
					<xsl:when test="$vitaDate/month != 0">
						<xsl:text> </xsl:text>
						<xsl:call-template name="MonthAsMMM">
							<xsl:with-param name="monthNumber" select="$vitaDate/month"/>
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="$vitaDate/day != 0">
								<xsl:text> </xsl:text>
								<xsl:value-of select="$vitaDate/day"/>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="emitVitaDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>

		<xsl:variable name="dFrom">
			<xsl:call-template name="VitaDateAsYMD">
				<xsl:with-param name="vitaDate" select="$startDate"/>
				<xsl:with-param name="ignorePresent" select="'true'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="dTo">
			<xsl:call-template name="VitaDateAsYMD">
				<xsl:with-param name="vitaDate" select="$endDate"/>
				<xsl:with-param name="ignorePresent" select="$ignorePresent"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($dFrom) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dFrom"/> - <xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$dFrom"/>
						<xsl:if test="$from='vivo'">
							- unspecified				
						</xsl:if>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:if test="$from='vivo'">
							unspecified	-			
						</xsl:if>						
						<xsl:value-of select="$dTo"/>
					</xsl:when>
					<!-- changed for vivo, dv uese "N/A" -->
					<xsl:otherwise> </xsl:otherwise>				
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="VitaDateAsYMD">
		<xsl:param name="vitaDate"/>
		<xsl:param name="ignorePresent"/>
		<xsl:choose>
			<xsl:when test="$vitaDate/present='true'">
				<xsl:if test="$ignorePresent='false'">Present</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$vitaDate/year &gt; 0">
						<xsl:choose>
							<xsl:when test="$vitaDate/month &gt; 0">
								<xsl:choose>
									<xsl:when test="$vitaDate/day &gt; 0">
										<!-- M/D/YYYY Format -->
										<xsl:value-of select="$vitaDate/month"/>/<xsl:value-of
											select="$vitaDate/day"/>/<xsl:value-of
											select="$vitaDate/year"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- M/YYYY Format -->
										<xsl:value-of select="$vitaDate/month"/>/<xsl:value-of
											select="$vitaDate/year"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!-- YYYY Format -->
								<xsl:value-of select="$vitaDate/year"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitCommitteeInfo">
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="emitVitaDateRange">
						<xsl:with-param name="startDate" select="dateRange/startDate"/>
						<xsl:with-param name="endDate" select="dateRange/endDate"/>
						<xsl:with-param name="ignorePresent" select="'false'"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="implode">
						<xsl:with-param name="values" select="role | committeeName"/>
						<xsl:with-param name="format" select="'role,committeeName'"/>
						<xsl:with-param name="delimiter" select="', '"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="EmitPeerReviewActivities">
		<xsl:if test="count(personsActivities[translate(@xsi:type,$uc,$lc)='editorialboard']) 
		+ count(personsActivities[translate(@xsi:type,$uc,$lc)='manuscriptreview']) 
		+ count(personsActivities[translate(@xsi:type,$uc,$lc)='grantproposalreview']) 
		+ count(personsActivities[translate(@xsi:type,$uc,$lc)='otherreviewactivity']) 
		+ count(personsActivities[translate(@xsi:type,$uc,$lc)='conferencematerialsreview'])&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em" space-after.optimum="1em">OTHER SCHOLARLY ACTIVITIES</fo:block>

			<xsl:call-template name="EmitPeerReviewActivityList">
				<xsl:with-param name="title" select="'Editorial Board(s)'"/>
				<xsl:with-param name="subtype" select="'EditorialBoard'"/>
			</xsl:call-template>

			<xsl:call-template name="EmitPeerReviewActivityList">
				<xsl:with-param name="title" select="'Manuscript Reviewer'"/>
				<xsl:with-param name="subtype" select="'ManuscriptReview'"/>
			</xsl:call-template>

			<xsl:call-template name="EmitPeerReviewActivityList">
				<xsl:with-param name="title" select="'Grant Reviewer'"/>
				<xsl:with-param name="subtype" select="'GrantProposalReview'"/>
			</xsl:call-template>

			<xsl:call-template name="EmitPeerReviewActivityList">
				<xsl:with-param name="title" select="'Conference Planning &amp; Review'"/>
				<xsl:with-param name="subtype" select="'ConferenceMaterialsReview'"/>
			</xsl:call-template>

			<xsl:call-template name="EmitPeerReviewActivityList">
				<xsl:with-param name="title" select="'Other Review Activities'"/>
				<xsl:with-param name="subtype" select="'OtherReviewActivity'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitPeerReviewActivityList">
		<xsl:param name="title"/>
		<xsl:param name="subtype"/>
		<xsl:if test="count(personsActivities[@xsi:type = $subtype]) &gt; 0">
			<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">
				<xsl:value-of select="$title"/>
			</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.0in"/>
				<fo:table-body>
					<xsl:for-each select="personsActivities[@xsi:type = $subtype]">
						<xsl:call-template name="EmitPeerReviewActivity">
							<xsl:with-param name="subtype" select="$subtype"/>
						</xsl:call-template>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitPeerReviewActivity">
		<xsl:param name="subtype"/>
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="emitVitaDateRange">
						<xsl:with-param name="startDate" select="dateRange/startDate"/>
						<xsl:with-param name="endDate" select="dateRange/endDate"/>
						<xsl:with-param name="ignorePresent" select="'false'"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:value-of select="normalize-space(role)"/>
					<xsl:choose>
						<xsl:when test="$subtype='EditorialBoard'">
							<xsl:if test="string-length(journalName) &gt; 0 and string-length(role) &gt; 0">, </xsl:if>
							<xsl:if test="string-length(journalName) &gt; 0"><xsl:value-of
									select="normalize-space(journalName)"/></xsl:if>
						</xsl:when>
						<xsl:when test="$subtype='GrantProposalReview'">
							<xsl:if test="string-length(agencyName) &gt; 0 and string-length(role) &gt; 0">, </xsl:if>
							<xsl:if test="string-length(agencyName) &gt; 0"><xsl:value-of
									select="normalize-space(agencyName)"/></xsl:if>
						</xsl:when>
						<xsl:when test="$subtype='ManuscriptReview'">
							<xsl:if test="string-length(journalName) &gt; 0 and string-length(role) &gt; 0">, </xsl:if>
							<xsl:if test="string-length(journalName) &gt; 0"><xsl:value-of
									select="normalize-space(journalName)"/></xsl:if>
						</xsl:when>
						<xsl:when test="$subtype='ConferenceMaterialsReview'">
							<xsl:if test="string-length(meetingDescription) &gt; 0 and string-length(role) &gt; 0">, </xsl:if>
							<xsl:if test="string-length(meetingDescription) &gt; 0"><xsl:value-of select="normalize-space(meetingDescription)"
								/></xsl:if>
						</xsl:when>
						<xsl:when test="$subtype='OtherReviewActivity'">
							<xsl:if test="string-length(description) &gt; 0">, <xsl:value-of
									select="normalize-space(description)"/></xsl:if>
						</xsl:when>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="dateKey">
		<xsl:param name="dateRecord"/>
		<xsl:value-of select="$dateRecord/year"/>
		<xsl:choose>
			<xsl:when test="string-length($dateRecord/month) = 1">0<xsl:value-of
					select="$dateRecord/month"/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dateRecord/month"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="string-length($dateRecord/day) = 1">0<xsl:value-of
					select="$dateRecord/day"/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dateRecord/day"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitTrainingEntry">
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<!-- build a date range list -->
					<xsl:choose>
						<xsl:when test="count(orderedTrainingDates) &gt; 0">
							<xsl:for-each select="orderedTrainingDates">
								<fo:block>
									<xsl:call-template name="emitVitaDateRange">
										<xsl:with-param name="startDate" select="startDate"/>
										<xsl:with-param name="endDate" select="endDate"/>
										<xsl:with-param name="ignorePresent" select="'false'"/>
									</xsl:call-template>
								</fo:block>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="dateOfDegree/year &gt; 0">
									<xsl:call-template name="VitaDateAsYMD">
										<xsl:with-param name="vitaDate" select="dateOfDegree"/>
										<xsl:with-param name="ignorePresent" select="'true'"/>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>	
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:if test="string-length(institution) &gt; 0">
						<fo:block><xsl:value-of select="normalize-space(institution)"/></fo:block>
					</xsl:if>
					<xsl:if test="string-length(location) &gt; 0">
						<fo:block><xsl:value-of select="normalize-space(location)"/></fo:block>
					</xsl:if>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:for-each select="trainingDegree">
						<xsl:value-of select="."/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</fo:block>
				<fo:block>
					<xsl:value-of select="discipline"/>
				</fo:block>
				<xsl:if test="string-length(majorAdvisor) &gt; 0">
					<fo:block>
						<xsl:value-of select="majorAdvisor"/>
					</fo:block>
				</xsl:if>
				<fo:block>
					<xsl:value-of select="honors"/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="EmitTrainingInformation">
		<xsl:param name="level"/>

		<xsl:choose>
			<xsl:when test="translate($level,$uc,$lc)='undergraduate'">
				<xsl:variable name="data" select="personsTrainings[trainingLevel='Undergraduate']"/>
				<xsl:for-each select="$data">
					
					<xsl:call-template name="EmitTrainingEntry"/>
					<xsl:if test="position() != last()">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="translate($level,$uc,$lc)='graduate'">
				<xsl:variable name="data" select="personsTrainings[trainingLevel='Graduate']"/>
				<xsl:for-each select="$data">
					
					<xsl:call-template name="EmitTrainingEntry"/>
					<xsl:if test="position() != last()">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="translate($level,$uc,$lc)='post-graduate'">
				<xsl:variable name="data" select="personsTrainings[trainingLevel='Post-Graduate']"/>
				<xsl:for-each select="$data">
					
					<xsl:call-template name="EmitTrainingEntry"/>
					<xsl:if test="position() != last()">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="translate($level,$uc,$lc)='vivotraining'">
				<xsl:variable name="data" select="personsTrainings[trainingLevel='vivoTraining']"/>
				<xsl:for-each select="$data">
					
					<xsl:call-template name="EmitTrainingEntry"/>
					<xsl:if test="position() != last()">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>


	</xsl:template>

	<xsl:template name="_testProfessorship">
		<xsl:param name="titles"/>

		<xsl:variable name="current" select="substring-before($titles, ';')"/>
		<xsl:variable name="remainder" select="substring-after($titles, ';')"/>
		<xsl:if test="string-length($remainder) &gt; 0">
			<xsl:call-template name="_testProfessorship">
				<xsl:with-param name="titles" select="$remainder"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length($current) &gt; 0">
			<xsl:if test="$current='professor'">
				<xsl:text>TRUE</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="_testAssociateProfessorship">
		<xsl:param name="titles"/>

		<xsl:variable name="current" select="substring-before($titles, ';')"/>
		<xsl:variable name="remainder" select="substring-after($titles, ';')"/>
		<xsl:if test="string-length($remainder) &gt; 0">
			<xsl:call-template name="_testAssociateProfessorship">
				<xsl:with-param name="titles" select="$remainder"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length($current) &gt; 0">
			<xsl:if test="contains($current,'associate professor')">
				<xsl:text>TRUE</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="_testAssistantProfessorship">
		<xsl:param name="titles"/>

		<xsl:variable name="current" select="substring-before($titles, ';')"/>
		<xsl:variable name="remainder" select="substring-after($titles, ';')"/>
		<xsl:if test="string-length($remainder) &gt; 0">
			<xsl:call-template name="_testAssistantProfessorship">
				<xsl:with-param name="titles" select="$remainder"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="string-length($current) &gt; 0">
			<xsl:if test="contains($current,'assistant professor')">
				<xsl:text>TRUE</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="APAPublicationDate">
		<xsl:param name="pubDate"/>
		<xsl:if test="$pubDate/year &gt; 0">
			<xsl:value-of select="$pubDate/year"/>
			<xsl:if test="$pubDate/month &gt; 0">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="MonthAsMMMM">
					<xsl:with-param name="monthNumber" select="$pubDate/month"/>
				</xsl:call-template>
				<xsl:if test="$pubDate/day &gt; 0">
					<xsl:text> </xsl:text>
					<xsl:value-of select="$pubDate/day"/>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CiteJournalArticle">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:if test="count(contributors) &gt; 0">
					<xsl:text>.  </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>
				<!-- Journal Title -->
				<xsl:if test="string-length(journalTitle) &gt; 0">
					<xsl:value-of select="normalize-space(journalTitle)"/>
					<xsl:text>.  </xsl:text>
				</xsl:if>
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="pvi"><xsl:call-template name="CitePageVolumeIssue"/></xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">
					<xsl:value-of select="normalize-space($pubDate)"/>
					<xsl:if test="string-length(normalize-space($pvi)) &gt; 0">
						<xsl:text>; </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="string-length($pvi)  &gt; 0">
					<xsl:value-of select="$pvi"/>
					<xsl:text>. </xsl:text>
				</xsl:if>
				<xsl:if test="string-length(pubMedCentralID) &gt; 0">
					<xsl:text>PubMed Central PMCID: </xsl:text>
					<xsl:value-of select="normalize-space(pubMedCentralID)"/>
					<xsl:text>. </xsl:text>
				</xsl:if>
				<xsl:if test="string-length(pubMedID) &gt; 0">
					<xsl:text>PubMed PMID: </xsl:text>
					<xsl:value-of select="normalize-space(pubMedID)"/>
				</xsl:if>				
			</xsl:when>
			
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="publicationDate/year != 0">(<xsl:call-template
						name="APAPublicationDate">
						<xsl:with-param name="pubDate" select="publicationDate"/>
					</xsl:call-template>).<xsl:text> </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>

				<xsl:if test="string-length(journalTitle) &gt; 0">
					<xsl:text> </xsl:text>
					<fo:inline font-style="italic">
						<xsl:value-of select="journalTitle"/>
					</fo:inline>
				</xsl:if>
				<xsl:if test="volume &gt; 0">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="normalize-space(volume)"/>
					<xsl:if test="issue &gt; 0">(<xsl:value-of select="issue"/>)</xsl:if>
				</xsl:if>
				<xsl:if test="string-length(pages) &gt; 0">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="normalize-space(pages)"/>
				</xsl:if>
				<xsl:text>. </xsl:text>
				<xsl:if test="string-length(pubMedCentralID) &gt; 0">
					<xsl:text>PubMed Central PMCID: </xsl:text>
					<xsl:value-of select="normalize-space(pubMedCentralID)"/>
					<xsl:text>. </xsl:text>
				</xsl:if>
				<xsl:if test="string-length(pubMedID) &gt; 0 and string-length(pubMedCentralID) &lt; 1 ">
					<xsl:text>PubMed PMID: </xsl:text>
					<xsl:value-of select="normalize-space(pubMedID)"/>
				</xsl:if>
				
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="nthFormatNumber">
		<xsl:param name="num"/>

		<xsl:choose>
			<xsl:when test="$num = 1">1st</xsl:when>
			<xsl:when test="$num = 2">2nd</xsl:when>
			<xsl:when test="$num = 3">3rd</xsl:when>
			<xsl:otherwise><xsl:value-of select="$num"/>th</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CiteBook">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:if test="count(contributors) &gt; 0">
					<xsl:text>. </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>
				
				<!-- Edition -->
				<xsl:choose>
					<xsl:when test="edition &gt; 0">
						<xsl:call-template name="nthFormatNumber">
							<xsl:with-param name="num" select="edition"/>
						</xsl:call-template>
						<xsl:if test="edition &gt; 1">
							rev<xsl:text>.  </xsl:text>
						</xsl:if>
						ed<xsl:text>.  </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(edition) &gt; 0">
							<xsl:if test="(substring(edition, 1, 1) &gt; 1) or (substring(edition, 1, 2) &gt; 9)">
							<xsl:value-of select="edition" />
								<xsl:text> rev. </xsl:text>
							</xsl:if>
							ed<xsl:text>. </xsl:text>
						</xsl:if>				
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- Publication Location -->
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
							<xsl:text>;</xsl:text>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="$pubDate"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
							<xsl:text>;</xsl:text>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:if test="string-length(publisher) &gt; 0">
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:value-of select="$pubDate"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitAPACitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">(<xsl:value-of
					select="normalize-space($pubDate)"/>)<xsl:text>. </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:if test="string-length(title) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="title"/>
						</xsl:call-template>
					</fo:inline>
					<!-- Edition -->
					<xsl:if test="edition &gt; 0">
						(<xsl:call-template name="nthFormatNumber">
							<xsl:with-param name="num" select="edition"/>
						</xsl:call-template>
						<xsl:if test="edition &gt; 1">
							rev<xsl:text>.  </xsl:text>
						</xsl:if>
						ed<xsl:text>.). </xsl:text>
					</xsl:if>
				</xsl:if>
				
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CiteBookChapter">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:if test="count(contributors) &gt; 0">
					<xsl:text>.  </xsl:text>
				</xsl:if>
				<!-- Chapter Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>

				<!-- Book Title -->
				<xsl:if test="string-length(bookTitle) &gt; 0"> In:<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>, editor<xsl:if test="count(editors)&gt; 1">s</xsl:if><xsl:text>.  </xsl:text>
					</xsl:if>
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="bookTitle"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Publication Location -->
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$pubDate"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:if test="string-length(publisher) &gt; 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="$pubDate"/>
							<xsl:text>. </xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>.  </xsl:text>
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0"><xsl:value-of
						select="normalize-space(pages)"/></xsl:if>
			</xsl:when>
			
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:variable name="pubDate"><xsl:call-template name="emitAPACitationVitaDate">
					<xsl:with-param name="vitaDate" select="publicationDate"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">(<xsl:value-of
					select="normalize-space($pubDate)"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:if test="string-length(title) &gt; 0">
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="title"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Book Title -->
				<xsl:if test="string-length(bookTitle) &gt; 0"> In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1">
							<xsl:text> (Eds.), </xsl:text>
						</xsl:if>
						<xsl:if test="count(editors) = 1">
							<xsl:text> (Ed.), </xsl:text>
						</xsl:if>
					</xsl:if>
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="bookTitle"/>
						</xsl:call-template>
					</fo:inline>
					<!-- Pages -->
					<xsl:if test="string-length(pages) &gt; 0">(<xsl:value-of
							select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				</xsl:if>

				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="CitePresentation">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:variable name="authors">
					<xsl:call-template name="EmitAuthorList">
						<xsl:with-param name="targetName" select="'authors'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($authors) &gt; 0">
					<xsl:value-of select="$authors"/>
					<xsl:if
						test="(substring($authors,string-length($authors),1) != '.') and (string-length($authors) &gt; 0)"
						>.</xsl:if>
					<xsl:text> </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="presentationTitle"/>
				</xsl:call-template>
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Presented at:
					<xsl:value-of select="normalize-space(meetingName)"	/>
				</xsl:if>
				<!-- Dates -->
				<xsl:variable name="mDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($mDates) &gt; 0">
					<xsl:if test="string-length(meetingName) &gt; 0">
						<xsl:text>; </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space($mDates)"/>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:if test="(string-length(meetingName) &gt; 0) or (string-length($mDates) &gt; 0)">
						<xsl:text>; </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(meetingLocation)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:variable name="authors">
					<xsl:call-template name="EmitAuthorList">
						<xsl:with-param name="targetName" select="'authors'"/>
					</xsl:call-template>
				</xsl:variable>
				<!--
				<xsl:value-of select="$authors"/> -->
				<xsl:if test="string-length($authors) &gt; 0">
					<xsl:value-of select="$authors"/>
					<xsl:if
						test="(substring($authors,string-length($authors),1) != '.') and (string-length($authors) &gt; 0)"/>
					<xsl:text>  </xsl:text>
				</xsl:if>
				<!-- Year -->
				<xsl:variable name="mDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($mDates) &gt; 0">
					(<xsl:value-of select="$mDates"
					/>)
					<xsl:text>. </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:if test="string-length(presentationTitle) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="presentationTitle"/>
						</xsl:call-template>
					</fo:inline>
				</xsl:if>
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Presented at
					<xsl:value-of select="normalize-space(meetingName)" />
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:if test="string-length(meetingName) &gt; 0">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(meetingLocation)"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CiteOtherPublication">
		<xsl:if test="string-length(citation) &gt; 0">
			<xsl:value-of select="citation"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CitePublishedAbstract">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:if test="count(contributors) &gt; 0">
					<xsl:text>.  </xsl:text>
				</xsl:if>
				<!-- Paper Title -->
				<xsl:if test="string-length(title)">
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="title"/>
					</xsl:call-template> [abstract] </xsl:if>
				<!-- Proceedings Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0"> In:<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>, editors<xsl:text>.  </xsl:text>
					</xsl:if>
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="proceedingsBookTitle"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Conference Title -->
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<xsl:value-of select="conferenceTitle"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
						<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0"><xsl:value-of select="$cDates"/>; </xsl:if>
				<!-- Conference Location -->
				<xsl:call-template name="EmitStringWithDelimiter">
					<xsl:with-param name="inString" select="conferenceLocation"/>
					<xsl:with-param name="charList" select="'.?!'"/>
					<xsl:with-param name="delimeter" select="'.'"/>
				</xsl:call-template>

				<!-- Publication Location -->
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$pubDate"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:if test="string-length(publisher) &gt; 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="$pubDate"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0"><xsl:text>. </xsl:text>
						<xsl:value-of select="normalize-space(pages)"/></xsl:if>
			</xsl:when>

			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="publicationDate/year != 0">(<xsl:value-of
						select="publicationDate/year"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:if test="string-length(title) &gt; 0">
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="presentationTitle"/>
					</xsl:call-template> [abstract]<xsl:text>.  </xsl:text></xsl:if>
				<!-- Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0"> In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1">
							<xsl:text> (Eds.), </xsl:text>
						</xsl:if>
						<xsl:if test="count(editors) = 1">
							<xsl:text> (Ed.), </xsl:text>
						</xsl:if>
					</xsl:if>
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="proceedingsBookTitle"/>
						</xsl:call-template>
					</fo:inline>
				</xsl:if>
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="conferenceTitle"/>
						<xsl:text>, </xsl:text>
					</fo:inline>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(conferenceLocation) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="conferenceLocation"/>
						<xsl:text>,  </xsl:text>
					</fo:inline>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
						<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="$cDates"/>
						<xsl:text> </xsl:text>
					</fo:inline>
				</xsl:if>

				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0">(<xsl:value-of
						select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CitePoster">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:variable name="authors">
					<xsl:call-template name="EmitAuthorList">
						<xsl:with-param name="targetName" select="'authors'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$authors"/>
				<xsl:if
					test="(string-length($authors) &gt; 0) and (substring($authors,string-length($authors),1) != '.')"
					>.</xsl:if>
				<xsl:text> </xsl:text>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="presentationTitle"/>
				</xsl:call-template>
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Poster presented at:
					<xsl:value-of select="normalize-space(meetingName)"/>
				</xsl:if>
				<!-- date -->
				<xsl:variable name="mDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($mDates) &gt; 0">
					<xsl:if test="string-length(meetingName) &gt; 0">
						<xsl:text>; </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space($mDates)"/>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:if test="(string-length(meetingName) &gt; 0) or (string-length($mDates) &gt; 0)">
						<xsl:text>; </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(meetingLocation)"/>
				</xsl:if>

			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:variable name="authors">
					<xsl:call-template name="EmitAuthorList">
						<xsl:with-param name="targetName" select="'authors'"/>
					</xsl:call-template>
				</xsl:variable>
				<!--
				<xsl:value-of select="$authors"/> -->
				<xsl:if test="string-length($authors) &gt; 0">
					<xsl:value-of select="$authors"/>
					<xsl:if
						test="(substring($authors,string-length($authors),1) != '.') and (string-length($authors) &gt; 0)"/>
					<xsl:text>  </xsl:text>
				</xsl:if>
				<!-- Year -->
				<xsl:variable name="mDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($mDates) &gt; 0">
					(<xsl:value-of select="$mDates"
					/>)
					<xsl:text>. </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:if test="string-length(presentationTitle) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="presentationTitle"/>
						</xsl:call-template>
					</fo:inline>
				</xsl:if>
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Poster session presented at
					<xsl:value-of select="normalize-space(meetingName)" />
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:if test="string-length(meetingName) &gt; 0">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(meetingLocation)"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CitePageNumbers">
		<xsl:param name="pCitation"/>
		<xsl:if test="string-length($pCitation) &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:if test="not(contains($pCitation, 'p'))">
				<xsl:text>p.</xsl:text>
			</xsl:if>
			<xsl:value-of select="$pCitation"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CiteConferencePaper">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>.  </xsl:text>
				<!-- Paper Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>

				<!-- Proceedings Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0"> In:<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>, editor<xsl:if test="count(editors) &gt; 1"
							>s</xsl:if><xsl:text>.  </xsl:text>
					</xsl:if>
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="proceedingsBookTitle"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Conference Title -->
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<xsl:value-of select="normalize-space(conferenceTitle)"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates">
					<xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
						<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length(normalize-space($cDates)) &gt; 0">
					<xsl:value-of select="normalize-space($cDates)"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:call-template name="EmitStringWithDelimiter">
					<xsl:with-param name="inString" select="conferenceLocation"/>
					<xsl:with-param name="charList" select="'.?!'"/>
					<xsl:with-param name="delimeter" select="'.'"/>
				</xsl:call-template>

				<!-- Publication Location -->
				<xsl:variable name="pubDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:text>; </xsl:text>
							<xsl:value-of select="$pubDate"/>
							<xsl:text>. </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
						<xsl:if test="string-length($pubDate) != 0">
							<xsl:if test="string-length(publisher) &gt; 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="$pubDate"/>
							<xsl:text>. </xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<!-- Pages -->
				<xsl:call-template name="CitePageNumbers">
					<xsl:with-param name="pCitation" select="normalize-space(pages)"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template>
				<xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="string-length(year) &gt; 0">(<xsl:value-of select="year"
					/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>

				<!-- Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0"> In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1">
							<xsl:text> (Eds.), </xsl:text>
						</xsl:if>
						<xsl:if test="count(editors) = 1">
							<xsl:text> (Ed.), </xsl:text>
						</xsl:if>
					</xsl:if>
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="proceedingsBookTitle"/>
						</xsl:call-template>
					</fo:inline>
				</xsl:if>
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="conferenceTitle"/>
						<xsl:text>, </xsl:text>
					</fo:inline>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(conferenceLocation) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="conferenceLocation"/>
						<xsl:text>,  </xsl:text>
					</fo:inline>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates">
					<xsl:call-template name="emitAPACitationVitaDateRange">
						<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
						<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0">
					<fo:inline font-style="italic">
						<xsl:value-of select="$cDates"/>
						<xsl:text> </xsl:text>
					</fo:inline>
				</xsl:if>

				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0">(pp. <xsl:value-of
						select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="substring(publicationLocation,string-length(publicationLocation),1) = '.'">
								<xsl:value-of select="substring(publicationLocation, 1, string-length(publicationLocation)-1)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(publisher)"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CitePatent">
		<xsl:call-template name="EmitAuthorList">
			<xsl:with-param name="targetName" select="'contributors'"/>
		</xsl:call-template>
		<xsl:if test="count(contributors) &gt; 0">
			<xsl:text>. </xsl:text>
		</xsl:if>
		<xsl:if test="title">
			<xsl:value-of select="normalize-space(title)"/>
			<xsl:text>. </xsl:text>
		</xsl:if>
		<xsl:if test="patentOrApplicationNumber">
			<xsl:value-of select="patentOrApplicationNumber"/>
			<xsl:text>. </xsl:text>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="(issueDate/year = 0) and (issueDate/present='false')">
				<!-- No issue date -->
				<xsl:variable name="appDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="applicationDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length(normalize-space($appDate)) &gt; 0"> 
					Filed on <xsl:value-of select="$appDate"/>
					<xsl:text>. </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- No issue date -->
				<xsl:variable name="issueDate">
					<xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="issueDate"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length(normalize-space($issueDate)) &gt; 0"> Issued on <xsl:value-of
						select="$issueDate"/>
					<xsl:text>. </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="citationFormat">
		<xsl:variable name="xsiType">
			<xsl:value-of select="translate(@xsi:type,$uc,$lc)"/>
		</xsl:variable>
		<xsl:variable name="citation">
			<xsl:choose>
				<xsl:when test="$xsiType='article'">
					<xsl:call-template name="CiteJournalArticle"/>
				</xsl:when>
				<xsl:when test="$xsiType='book'">
					<xsl:call-template name="CiteBook"/>
				</xsl:when>
				<xsl:when test="$xsiType='otherpublication'">
					<xsl:call-template name="CiteOtherPublication"/>
				</xsl:when>
				<xsl:when test="$xsiType='chapter'">
					<xsl:call-template name="CiteBookChapter"/>
				</xsl:when>
				<xsl:when test="$xsiType='publishedabstract'">
					<xsl:call-template name="CitePublishedAbstract"/>
				</xsl:when>
				<xsl:when test="$xsiType='conferencepaper'">
					<xsl:call-template name="CiteConferencePaper"/>
				</xsl:when>
				<xsl:when test="local-name()='personsPresentations'">
					<xsl:choose>
						<xsl:when test="translate(@xsi:type,$uc,$lc)='poster'">
							<xsl:call-template name="CitePoster"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="CitePresentation"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="publicationStatus='submitted'"> (submitted)</xsl:if>
			<xsl:if test="publicationStatus='accepted'"> (accepted)</xsl:if>
			<xsl:if test="publicationStatus='in press'"> (in press)</xsl:if>
			<xsl:if test="local-name()!='personsPresentations'">
				<xsl:if test="invited='true'"> (invited)</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<xsl:variable name="ncite" select="normalize-space($citation)"/>
				<xsl:variable name="lastChar" select="substring($ncite, string-length($ncite), 1)"/>
				<xsl:value-of select="normalize-space($ncite)"/>
				<xsl:if test="($lastChar != '!') and ($lastChar != '?') and ($lastChar != '.')">
					<xsl:text>.</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$citation"/><xsl:variable name="ncite" 
				select="normalize-space($citation)"/><xsl:variable name="lastChar" 
					select="substring($ncite, string-length($ncite), 1)"/><xsl:if test="($lastChar != '!') and ($lastChar != '?') and ($lastChar != '.')">
					<xsl:text>.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<!-- ERR 11/19/08 BEGIN -->
	<xsl:template name="emitCurrentSchool">
		<xsl:for-each select="//personsProfessionalPositions[dateRange/endDate/present='false']">
			<xsl:if test="position()=1">
				<xsl:value-of select="normalize-space(school)"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- ERR 11/19/08 END -->
	<!-- ERR 11/11/08 BEGIN - added implementation of 'implode' function -->
	<xsl:template name="_getValueFromSubSet">
		<xsl:param name="values"/>
		<xsl:param name="target"/>
		<xsl:for-each select="$values">
			<xsl:if test="local-name(.) = $target">
				<xsl:value-of select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="_available">
		<xsl:param name="values"/>
		<xsl:param name="format"/>
		<xsl:for-each select="$values">[<xsl:value-of select="local-name(.)"/>]</xsl:for-each>
	</xsl:template>
	<xsl:template name="_implode_output">
		<xsl:param name="values"/>
		<xsl:param name="format"/>
		<xsl:param name="delimiter"/>
		<xsl:variable name="current" select="substring-before($format, ':')"/>
		<xsl:variable name="remainder" select="substring-after($format, ':')"/>
		<xsl:call-template name="_getValueFromSubSet">
			<xsl:with-param name="values" select="$values"/>
			<xsl:with-param name="target" select="$current"/>
		</xsl:call-template>
		<xsl:if test="string-length($remainder) &gt; 0">
			<xsl:value-of select="$delimiter"/>
			<xsl:call-template name="_implode_output">
				<xsl:with-param name="values" select="$values"/>
				<xsl:with-param name="format" select="$remainder"/>
				<xsl:with-param name="delimiter" select="$delimiter"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="_reduce">
		<xsl:param name="format"/>
		<xsl:param name="available"/>
		<xsl:variable name="current">
			<xsl:choose>
				<xsl:when test="string-length(substring-before($format, ',')) &gt; 0">
					<xsl:value-of select="substring-before($format, ',')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$format"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="remainder" select="substring-after($format, ',')"/>
		<xsl:if test="contains($available, concat('[', $current, ']'))"><xsl:value-of
				select="$current"/>:</xsl:if>
		<xsl:if test="string-length($remainder) &gt; 0">
			<xsl:call-template name="_reduce">
				<xsl:with-param name="format" select="$remainder"/>
				<xsl:with-param name="available" select="$available"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="_traverse">
		<xsl:param name="values"/>
		<xsl:param name="format"/>
		<xsl:param name="delimiter"/>
		<!-- Create a variable which contains the names of the elements which

			 are included in the value set (i.e. which have non-empty content) -->
		<xsl:variable name="aList">
			<xsl:call-template name="_available">
				<xsl:with-param name="values" select="$values"/>
				<xsl:with-param name="format" select="$format"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Take the passed-in format list and remove all of the elements which

			 are not in the aList -->
		<xsl:variable name="fList">
			<xsl:call-template name="_reduce">
				<xsl:with-param name="format" select="$format"/>
				<xsl:with-param name="available" select="$aList"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- fList represents the intersection of the format list and the

			 available data -->
		<xsl:call-template name="_implode_output">
			<xsl:with-param name="values" select="$values"/>
			<xsl:with-param name="format" select="$fList"/>
			<xsl:with-param name="delimiter" select="$delimiter"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="implode">
		<!-- Given a list of elements, strip out all of the ones which do not have any content

		 in them, then spit them out one at a time, separated by the given delimiter -->
		<xsl:param name="values"/>
		<xsl:param name="format"/>
		<xsl:param name="delimiter" select="', '"/>
		<!-- Strip out all of the elements which do not have any content in them -->
		<xsl:call-template name="_traverse">
			<xsl:with-param name="values" select="$values[string-length(.) &gt; 0]"/>
			<xsl:with-param name="format" select="$format"/>
			<xsl:with-param name="delimiter" select="$delimiter"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="data">
		<xsl:call-template name="implode">
			<xsl:with-param name="values" select="title | department | institution"/>
			<xsl:with-param name="format" select="'title,department,institution'"/>
			<xsl:with-param name="delimiter" select="', '"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ERR 11/11/08 END -->

	<!-- ERR 12/09/08 BEGIN -->
	<xsl:template name="formatDate">
		<!-- 'value' should be an oracle date string (1992-06-01T00:00:00-05:00)
		'format' is one of the following strings:
			'Y' => 1992
			'YM' => 6/1992
			'YMD' => 6/1/1992
		-->
		<xsl:param name="format" select="'Y'"/>
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="$format='Y'">
				<xsl:value-of select="substring($value, 1, 4)"/>
			</xsl:when>
			<xsl:when test="$format='YM'">
				<xsl:value-of select="format-number(substring($value,6,2), '#')"/>/<xsl:value-of
					select="substring($value, 1, 4)"/>
			</xsl:when>
			<xsl:when test="$format='YMD'">
				<xsl:value-of select="format-number(substring($value,6,2), '#')"/>/<xsl:value-of
					select="format-number(substring($value, 8, 2),'#')"/>/<xsl:value-of
					select="substring($value, 1, 4)"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="emitTrainingDateRange">
		<xsl:param name="start_date"/>
		<xsl:param name="end_date"/>
		<xsl:param name="format" select="'Y'"/>
		<!-- 
			"start_date" and "end_date" are nodes:	
			<endDate>
				<id>29</id>
				<merged>false</merged>
				<present>false</present>
				<month/>
				<year/>
			</endDate>		
		-->
		<xsl:choose>
			<xsl:when test="$start_date/present='false'">
				<xsl:value-of select="$start_date/month"/>/<xsl:value-of select="$start_date/year"/>
				<xsl:choose>
					<xsl:when test="$end_date/present='false'"> -<xsl:value-of
							select="$end_date/month"/>/<xsl:value-of select="$end_date/year"/>
					</xsl:when>
					<xsl:otherwise>-present</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$end_date/present='false'">
						<xsl:value-of select="$end_date/month"/>/<xsl:value-of
							select="$end_date/year"/>
					</xsl:when>
					<xsl:otherwise>present</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	<!-- ERR 12/09/08 END -->

	<!-- ERR 11/19/08 BEGIN -->
	<xsl:template name="emitYearRange">
		<xsl:param name="start_year"/>
		<xsl:param name="end_year"/>
		<!-- 
			"start_year" is an integer 
			"end_year" is a node:
				<endYear>
					<id>29</id>
					<merged>false</merged>
					<presentYear>true</presentYear>
					<year>0</year>
				</endYear>
		-->
		<xsl:choose>
			<xsl:when test="$start_year !=0">
				<xsl:value-of select="$start_year"/>
				<xsl:choose>
					<xsl:when test="$end_year/year != 0">-<xsl:value-of select="$end_year/year"
						/></xsl:when>
					<xsl:otherwise>-present</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$end_year/year != 0">
						<xsl:value-of select="$end_year/year"/>
					</xsl:when>
					<xsl:otherwise>present</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="emitYearRangeBothNodes">
		<xsl:param name="start_year"/>
		<xsl:param name="end_year"/>
		<!-- 
			"start_year"  &
			"end_year" are nodes:
				<endYear>
					<id>29</id>
					<merged>false</merged>
					<presentYear>true</presentYear>
					<year>0</year>
				</endYear>
		-->
		<xsl:choose>
			<xsl:when test="$start_year/year !=0">
				<xsl:value-of select="$start_year/year"/>
				<xsl:choose>
					<xsl:when test="$end_year/year != 0">-<xsl:value-of select="$end_year/year"
						/></xsl:when>
					<xsl:otherwise>-present</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$end_year/year != 0">
						<xsl:value-of select="$end_year/year"/>
					</xsl:when>
					<xsl:otherwise>present</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ERR 11/19/08 END -->

	<xsl:template name="EmitAuthorList">
		<xsl:param name="targetName"/>
		<xsl:choose>
			<xsl:when test="$citationFormat='apa'">
				<!-- APA format has special rules for lists of people:
					one author: list the name followed by a period
					two authors: first name, & second name followed by a period
					3-6 authors: all names separated by commas, last preceded by 
								 an ampersand and followed by a period
								 7 or more: first six authors, ..., last author, period. -->
				<xsl:variable name="authorCount" select="count(node()[local-name()=$targetName])"/>
				<xsl:choose>
					<xsl:when test="$authorCount = 1">
						<xsl:for-each select="node()[local-name()=$targetName]">
							<xsl:variable name="personName">
								<xsl:call-template name="EmitPerson"/>
							</xsl:variable>
							<xsl:value-of select="normalize-space($personName)"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="($authorCount &gt;= 2) and ($authorCount &lt;= 7)">
						<xsl:for-each select="node()[local-name()=$targetName]">
							<xsl:variable name="personName">
								<xsl:call-template name="EmitPerson"/>
							</xsl:variable>
							<xsl:value-of select="normalize-space($personName)"/>
							<xsl:if test="position() != last()">
								<xsl:text>, </xsl:text>
								<xsl:if test="position()=last()-1">
									<xsl:text>&amp; </xsl:text>
								</xsl:if>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$authorCount &gt; 7">
						<xsl:for-each select="node()[local-name()=$targetName]">
							<xsl:choose>
								<xsl:when test="position() &lt; 7">
									<xsl:variable name="personName">
										<xsl:call-template name="EmitPerson"/>
									</xsl:variable>
									<xsl:value-of select="normalize-space($personName)"/>
									<xsl:text>, </xsl:text>
								</xsl:when>
								<xsl:when test="position() = last()">
									<xsl:variable name="personName">
										<xsl:call-template name="EmitPerson"/>
									</xsl:variable>
									<xsl:text>...</xsl:text>
									<xsl:value-of select="normalize-space($personName)"/>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$citationFormat='vancouver'">
				<xsl:for-each select="node()[local-name()=$targetName]">
					<xsl:variable name="personName">
						<xsl:call-template name="EmitPerson"/>
					</xsl:variable>
					<xsl:value-of select="normalize-space($personName)"/>
					<xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitEditorList">
		<xsl:param name="targetName"/>
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="$targetName"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="node()[local-name()=$targetName]">
					
					<xsl:variable name="personName">
						<xsl:call-template name="EmitPerson"/>
					</xsl:variable>
					<xsl:value-of select="normalize-space($personName)"/>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
						<xsl:if
							test="(count(node()[local-name()=$targetName]) &gt; 1) and (position() = last()-1)">
							<xsl:text>&#38; </xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--  ERR 11/19/08 BEGIN -->
	<xsl:template name="EmitPerson">
		<xsl:if test="$citationFormat = 'apa'">
			<xsl:choose>
				<!-- Author Format -->
				<xsl:when test="(local-name()='contributors') or (local-name() = 'authors')">
					<xsl:value-of select="familyName"/>
					<xsl:choose>
						<xsl:when test="string-length(givenName) &gt; 0">
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:text>, </xsl:text>
									<xsl:value-of select="substring(givenName, 1, 1)"/>
									<xsl:text>. </xsl:text>
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>, </xsl:text>
									<xsl:value-of select="substring(givenName, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:text>, </xsl:text>
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Editor format -->
				<xsl:when test="local-name()='editors'">
					<xsl:choose>
						<xsl:when test="string-length(givenName) &gt; 0">
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:value-of select="substring(givenName, 1, 1)"/>
									<xsl:text>. </xsl:text>
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring(givenName, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
									<xsl:text>.</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="string-length(familyName) &gt; 0">
						<xsl:text> </xsl:text>
						<xsl:value-of select="familyName"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$citationFormat = 'vancouver'">
			<xsl:choose>
				<xsl:when test="string-length(displayName) &gt; 0">
					<xsl:value-of select="displayName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="familyName"/>
					<xsl:choose>
						<xsl:when test="string-length(givenName) &gt; 0">
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:text> </xsl:text>
									<xsl:value-of select="substring(givenName, 1, 1)"/>
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
									<xsl:value-of select="substring(givenName, 1, 1)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
									<xsl:text> </xsl:text>
									<xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!--  ERR 11/19/08 END -->


	<!-- ERR 12/16/08 BEGIN -->
	<xsl:template name="EmitAddress">
		<xsl:param name="address"/>
		<fo:block>
			<xsl:choose>
			<xsl:when
				test="(string-length($address/city) = 0) and (string-length($address/stateOrProvince) = 2)">
				<!-- Filter out places where we fill in the state as "PA", even if the user has 
					 not supplied the rest of the address -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length($address/street1) + string-length($address/street2) &gt; 0">
					<fo:block wrap-option="wrap">
						<xsl:if test="$address/street1!=''">
							<xsl:value-of select="$address/street1"/>
						</xsl:if>
					</fo:block>
					<fo:block wrap-option="wrap">
						<xsl:if test="$address/street2!=''">
							<xsl:value-of select="$address/street2"/>
						</xsl:if>
					</fo:block>
				</xsl:if>
				<xsl:if test="string-length($address/city) + string-length($address/stateOrProvince) + string-length($address/postalCode) &gt; 0">
					<fo:block>
						<xsl:if test="$address/city!=''"><xsl:value-of select="$address/city"/>, </xsl:if>
						<xsl:if test="$address/stateOrProvince!=''"><xsl:value-of
							select="$address/stateOrProvince"/>&#160;</xsl:if>
						<xsl:if test="$address/postalCode!=''">
							<xsl:value-of select="$address/postalCode"/>
						</xsl:if>
					</fo:block>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		</fo:block>
	</xsl:template>

	<!-- ERR 12/20/08 END -->

	<xsl:template name="EmitHeader">

		<fo:wrapper xsl:use-attribute-sets="h1">
			<fo:block>CURRICULUM VITAE</fo:block>

			<fo:wrapper xsl:use-attribute-sets="h2">
				<fo:block>
					<!-- changed for vivo -->
					<xsl:choose>
						<xsl:when test="(string-length(person/givenName) &gt; 0) and (string-length(person/familyName) &gt; 0) ">	
							<xsl:value-of select="person/givenName"/><xsl:text> </xsl:text>
							<xsl:value-of select="substring(person/middleNameOrInitial,1,1)"/><xsl:text> </xsl:text>
							<xsl:value-of select="person/familyName"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="person/fullName"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:if test="string-length(person/degreeListing) &gt; 0">
						,&#160;
						<xsl:value-of select="person/degreeListing"/>
					</xsl:if>
				</fo:block>

				<xsl:variable name="currentSchool" select="//personsProfessionalPositions[endYear/year=0][1]/school"/>
				<xsl:choose>
					<xsl:when test="string-length($currentSchool) &gt; 0">						
						<fo:block>University of Pittsburgh</fo:block>
						<fo:block space-after="8pt">
							<xsl:value-of select="$currentSchool"/>
						</fo:block>
					</xsl:when>
					
				</xsl:choose>
				
				<!-- added for vivo, position at the heading-->
				<xsl:variable name="vivoPosition" select="//personsProfessionalPositions[endYear/year=''][1]/institution"/>
				<xsl:choose>
					<xsl:when test="string-length($vivoPosition) &gt; 0">
						<fo:block space-after="8pt">
							<xsl:value-of select="$vivoPosition"/>
						</fo:block>
					</xsl:when>
				</xsl:choose>				
				
				
				<fo:block>&#xa0;</fo:block>
			</fo:wrapper>
		</fo:wrapper>
	</xsl:template>

	<xsl:template name="PruneBioFieldList">
		<xsl:param name="fieldNames"/>

		<xsl:variable name="currentFieldName" select="substring-before($fieldNames, ',')"/>
		<xsl:variable name="remainingFields" select="substring-after($fieldNames, ',')"/>

		<xsl:variable name="fieldValue">
			<xsl:call-template name="GetBioFieldValue">
				<xsl:with-param name="fName" select="$currentFieldName"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($fieldValue) &gt; 0">
			<xsl:value-of select="$currentFieldName"/>
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:if test="string-length($remainingFields) &gt; 0">
			<xsl:call-template name="PruneBioFieldList">
				<xsl:with-param name="fieldNames" select="$remainingFields"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitBioRows">
		<xsl:param name="fieldNames"/>

		<xsl:if test="string-length($fieldNames) &gt; 0">
			<!-- Get the left & right cell values -->
			<xsl:variable name="leftCellFieldName" select="substring-before($fieldNames,',')"/>
			<xsl:variable name="remaining" select="substring-after($fieldNames, ',')"/>
			<xsl:variable name="rightCellFieldName" select="substring-before($remaining,',')"/>
			<xsl:variable name="nextRows" select="substring-after($remaining, ',')"/>
			<fo:table-row>
				<xsl:call-template name="EmitBioField">
					<xsl:with-param name="fName" select="$leftCellFieldName"/>
				</xsl:call-template>
				<xsl:call-template name="EmitBioField">
					<xsl:with-param name="fName" select="$rightCellFieldName"/>
				</xsl:call-template>
			</fo:table-row>
			<xsl:if test="string-length($nextRows) &gt; 0">
				<xsl:call-template name="EmitBioRows">
					<xsl:with-param name="fieldNames" select="$nextRows"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template name="EmitBioFromList">
		<xsl:param name="fieldNames"/>
		<xsl:param name="fieldsPlaced"/>

		<xsl:variable name="populatedFields">
			<xsl:call-template name="PruneBioFieldList">
				<xsl:with-param name="fieldNames" select="$fieldNames"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Populated Fields = <xsl:value-of select="$populatedFields"/> -->

		<fo:table xsl:use-attribute-sets="table">
			<fo:table-column column-width="1.25in"/>
			<fo:table-column column-width="2.15in"/>
			<fo:table-column column-width="1.60in"/>
			<fo:table-column column-width="2.30in"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell number-columns-spanned="4">
						<fo:block/>
					</fo:table-cell>
				</fo:table-row>

				<xsl:call-template name="EmitBioRows">
					<xsl:with-param name="fieldNames" select="$populatedFields"/>
				</xsl:call-template>
			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template name="GetBioFieldCaption">
		<xsl:param name="fName"/>
		<xsl:choose>
			<xsl:when test="$fName = 'home_address'">Home Address:</xsl:when>
			<xsl:when test="$fName = 'birthplace'">Birthplace:</xsl:when>
			<xsl:when test="$fName = 'home_phone'">Home Phone:</xsl:when>
			<xsl:when test="$fName = 'citizenship'">Citizenship:</xsl:when>
			<xsl:when test="$fName = 'business_address'">Business Address:</xsl:when>
			<xsl:when test="$fName = 'email_address'">Email Address:</xsl:when>
			<xsl:when test="$fName = 'business_phone'">Business Phone:</xsl:when>
			<xsl:when test="$fName = 'business_fax'">Business Fax:</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="GetBioFieldValue">
		<xsl:param name="fName"/>
		<xsl:choose>
			<xsl:when test="$fName = 'home_address'">
				<xsl:call-template name="EmitAddress">
					<xsl:with-param name="address" select="personsPostalAddresses[use='home']"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$fName = 'birthplace'">
				<xsl:value-of select="person/birthPlace"/>
			</xsl:when>
			<xsl:when test="$fName = 'home_phone'">
				<xsl:value-of
					select="personsTelephoneContacts[use='home' and device='phone']/phoneNumber"/>
			</xsl:when>
			<xsl:when test="$fName = 'citizenship'">
				<xsl:value-of select="person/citizenship"/>
			</xsl:when>
			<xsl:when test="$fName = 'business_address'">
				<xsl:call-template name="EmitAddress">
					<xsl:with-param name="address" select="personsPostalAddresses[use='business']"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$fName = 'email_address'">
				<xsl:value-of select="personsEmailContacts[use='business']/emailAddress"/>
			</xsl:when>
			<xsl:when test="$fName = 'business_phone'">
				<xsl:value-of
					select="personsTelephoneContacts[use='business' and device='phone']/phoneNumber"
				/>
			</xsl:when>
			<xsl:when test="$fName = 'business_fax'">
				<xsl:value-of
					select="personsTelephoneContacts[use='business' and device='fax']/phoneNumber"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitBioField">
		<xsl:param name="fName"/>

		<xsl:choose>
			<xsl:when test="$fName = 'home_address'">
				<fo:table-cell>
					<fo:block font-weight="bold">Home Address:</fo:block>
				</fo:table-cell>
				<fo:table-cell padding-end="1em">
					<xsl:call-template name="EmitAddress">
						<xsl:with-param name="address" select="personsPostalAddresses[use='home']"/>
					</xsl:call-template>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'birthplace'">
				<fo:table-cell>
					<fo:block font-weight="bold">Birthplace:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of select="person/birthPlace"/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'home_phone'">
				<fo:table-cell>
					<fo:block font-weight="bold">Home Phone:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of
							select="personsTelephoneContacts[use='home' and device='phone']/phoneNumber"
						/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>
			<xsl:when test="$fName = 'citizenship'">
				<fo:table-cell>
					<fo:block font-weight="bold">Citizenship:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of select="person/citizenship"/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'business_address'">
				<fo:table-cell>
					<fo:block font-weight="bold">Business Address:</fo:block>
				</fo:table-cell>
				<fo:table-cell padding-end="1em">
					<xsl:call-template name="EmitAddress">
						<xsl:with-param name="address"
							select="personsPostalAddresses[use='business']"/>
					</xsl:call-template>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'email_address'">
				<fo:table-cell>
					<fo:block font-weight="bold">Email Address:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of select="personsEmailContacts[use='business']/emailAddress"/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'business_phone'">
				<fo:table-cell>
					<fo:block font-weight="bold">Business Phone:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of
							select="personsTelephoneContacts[use='business' and device='phone']/phoneNumber"
						/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>

			<xsl:when test="$fName = 'business_fax'">
				<fo:table-cell>
					<fo:block font-weight="bold">Business Fax:</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:value-of
							select="personsTelephoneContacts[use='business' and device='fax']/phoneNumber"/>
					</fo:block>
				</fo:table-cell>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitBiographicalInformation">
		<xsl:call-template name="EmitBioFromList">
			<xsl:with-param name="fieldNames"
				select="'home_address,birthplace,home_phone,citizenship,business_address,email_address,business_phone,business_fax,'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="EmitEducation">
		<xsl:if test="count(personsTrainings[trainingLevel='Undergraduate' or trainingLevel='Graduate' or trainingLevel='Post-Graduate' or trainingLevel='vivoTraining'])&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt" space-after.optimum="1em">EDUCATION and TRAINING</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="3.0in"/>
				<fo:table-column column-width="2.5in"/>
				<fo:table-body>
					<xsl:if test="count(personsTrainings[trainingLevel='Undergraduate'])&gt;0">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block font-weight="bold">Undergraduate</fo:block>
							</fo:table-cell>
						</fo:table-row>

						<xsl:call-template name="EmitTrainingInformation">
							<xsl:with-param name="level" select="'Undergraduate'"/>
						</xsl:call-template>

						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
					
					<xsl:if test="count(personsTrainings[trainingLevel='Graduate'])&gt;0">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block font-weight="bold">Graduate</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:call-template name="EmitTrainingInformation">
							<xsl:with-param name="level" select="'Graduate'"/>
						</xsl:call-template>
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block>&#xa0;</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
					
					<xsl:if test="count(personsTrainings[trainingLevel='Post-Graduate'])&gt;0">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block font-weight="bold">Postgraduate</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:call-template name="EmitTrainingInformation">
							<xsl:with-param name="level" select="'Post-Graduate'"/>
						</xsl:call-template>
					</xsl:if>
					
					<xsl:if test="count(personsTrainings[trainingLevel='vivoTraining'])&gt;0">
						<xsl:call-template name="EmitTrainingInformation">
							<xsl:with-param name="level" select="'vivoTraining'"/>
						</xsl:call-template>
					</xsl:if>
					
					
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitAppointments">
		<xsl:if test="count(personsProfessionalPositions)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt"
				space-after.optimum="1em">APPOINTMENTS and POSITIONS</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="3.0in"/>
				<fo:table-column column-width="2.3in"/>
				<fo:table-body>
					<xsl:if test="count(personsProfessionalPositions[academic='true' or academic=''])&gt;0">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block font-weight="bold">Academic</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="personsProfessionalPositions[academic='true' or academic='']">
							<fo:table-row>
								<fo:table-cell padding-after="1em">
									<fo:block>
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate" select="dateRange/startDate"/>
											<xsl:with-param name="endDate" select="dateRange/endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell padding-after="1em">
									<fo:block>
										<xsl:value-of select="normalize-space(school)"/>
									</fo:block>
									<xsl:for-each select="institution">
										<fo:block>
											<xsl:value-of select="text()"/>
										</fo:block>
									</xsl:for-each>
									<fo:block>
										<xsl:value-of select="normalize-space(location)"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell padding-after="1em">
									<fo:block>
										<xsl:value-of select="normalize-space(title)"/>
									</fo:block>
									<fo:block>
										<xsl:value-of select="normalize-space(department)"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="count(personsProfessionalPositions[academic='false'])&gt;0">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="3">
								<fo:block font-weight="bold">Non-Academic</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="personsProfessionalPositions[academic='false']">
							<fo:table-row>
								<fo:table-cell>
									<fo:block>
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate" select="dateRange/startDate"/>
											<xsl:with-param name="endDate" select="dateRange/endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell padding-after="1em">
									<fo:block>
										<xsl:value-of select="normalize-space(school)"/>
									</fo:block>
									<xsl:for-each select="institution">
										<fo:block>
											<xsl:value-of select="text()"/>
										</fo:block>
									</xsl:for-each>
									<fo:block>
										<xsl:value-of select="normalize-space(location)"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell padding-after="1em">
									<fo:block>
										<xsl:value-of select="normalize-space(title)"/>
									</fo:block>
									<fo:block>
										<xsl:value-of select="normalize-space(department)"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:if>
			
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitLicense">
		<xsl:param name="includeSpace"/>
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:if test="(issueDate/year = 0) and (expirationDate/year &gt; 0)">
						Expires </xsl:if>
					<xsl:call-template name="emitVitaDateRange">
						<xsl:with-param name="startDate" select="issueDate"/>
						<xsl:with-param name="endDate" select="expirationDate"/>
						<xsl:with-param name="ignorePresent" select="'false'"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<xsl:if test="string-length(grantingAuthority) &gt; 0">
					<fo:block>
						<xsl:value-of select="grantingAuthority"/>
					</fo:block>
				</xsl:if>
				<fo:block>
					<xsl:call-template name="implode">
						<xsl:with-param name="values" select="type | licenseNumber"/>
						<xsl:with-param name="format" select="'type,licenseNumber'"/>
						<xsl:with-param name="delimiter" select="', '"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		<xsl:if test="$includeSpace">
			<fo:table-row>
				<fo:table-cell>
					<fo:block>&#xa0;</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</xsl:if>
	</xsl:template>

	<xsl:template name="SpecialtyLicenses">
		<fo:block font-weight="bold" text-align="left" space-after.optimum="1em">Specialty Certification</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.0in"/>
				<fo:table-body>
					<xsl:for-each select="personsLicenseOrCertificates[specialty='true']">
						<xsl:call-template name="EmitLicense">
							<xsl:with-param name="includeSpace" select="position()!=last()"/>
						</xsl:call-template>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
	</xsl:template>

	<xsl:template name="MedicalLicenses">
			<fo:block font-weight="bold" text-align="left" space-after.optimum="1em">Medical or Other Professional Licensure</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.0in"/>
				<fo:table-body>
					<xsl:for-each select="personsLicenseOrCertificates[specialty='false']">
						<xsl:call-template name="EmitLicense">
							<xsl:with-param name="includeSpace" select="position()!=last()"/>
						</xsl:call-template>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
	</xsl:template>

	<!-- added for vivo -->
	<xsl:template name="vivoLicenses">
		<fo:table xsl:use-attribute-sets="table">
			<fo:table-column column-width="1.75in"/>
			<fo:table-column column-width="5.0in"/>
			<fo:table-body>
				<xsl:for-each select="personsLicenseOrCertificates[specialty='vivoLicenses']">
					<xsl:call-template name="EmitLicense">
						<xsl:with-param name="includeSpace" select="position()!=last()"/>
					</xsl:call-template>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template name="EmitLicenses">
		<xsl:if test="count(personsLicenseOrCertificates) &gt; 0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt"
				space-after.optimum="1em">CERTIFICATION and LICENSURE</fo:block>
			<xsl:if test="count(personsLicenseOrCertificates[specialty='true'])&gt;0">			
				<xsl:call-template name="SpecialtyLicenses"/>
			</xsl:if>
			<xsl:if test="(count(personsLicenseOrCertificates[specialty='true'])&gt;0) and (count(personsLicenseOrCertificates[specialty='false'])&gt;0)">
				<fo:block space-before="20pt"> </fo:block>	
			</xsl:if>
			<xsl:if test="count(personsLicenseOrCertificates[specialty='false'])&gt;0">			
				<xsl:call-template name="MedicalLicenses"/>
			</xsl:if>
			<!-- added for vivo -->
			<xsl:if test="count(personsLicenseOrCertificates[specialty='vivoLicenses'])&gt;0">			
				<xsl:call-template name="vivoLicenses"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitMemberships">
		<xsl:if
			test="count(personsActivities[translate(@xsi:type,$uc,$lc)='profsocietymembership'])&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt"
				space-after.optimum="1em">MEMBERSHIP in PROFESSIONAL and SCIENTIFIC
				SOCIETIES</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.0in"/>
				<fo:table-body>
					<xsl:for-each
						select="personsActivities[translate(@xsi:type,$uc,$lc)='profsocietymembership']">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="emitVitaDateRange">
										<xsl:with-param name="startDate" select="dateRange/startDate"/>
										<xsl:with-param name="endDate" select="dateRange/endDate"/>
										<xsl:with-param name="ignorePresent" select="'false'"/>
									</xsl:call-template>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:choose>
										<xsl:when test="string-length(role) &gt; 0">
											<xsl:value-of select="normalize-space(role)"/>
											<xsl:if test="string-length(societyName) &gt; 0">
												<xsl:text>, </xsl:text>
												<xsl:value-of select="societyName"/>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="societyName"/>
										</xsl:otherwise>
									</xsl:choose>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitAwards">
		<xsl:if test="count(personsHonors)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt"
				space-after.optimum="1em">HONORS and AWARDS</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.0in"/>
				<fo:table-body>
					<xsl:for-each select="personsHonors">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="emitVitaDateRange">
										<xsl:with-param name="startDate"
											select="dateRange/startDate"/>
										<xsl:with-param name="endDate" select="dateRange/endDate"/>
										<xsl:with-param name="ignorePresent" select="'false'"/>
									</xsl:call-template>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:value-of select="normalize-space(title)"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitPublications">
		<xsl:if test="count(personsPublications)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt" space-after.optimum="1em">PUBLICATIONS</fo:block>
		</xsl:if>
		<xsl:if
			test="count(personsPublications[peerReviewed='true' and (@xsi:type != 'publishedAbstract')])&gt;0  
				or ((string-length($isAssociateProfessor) &gt; 0) 
					or (string-length($isProfessor) &gt; 0))">
			<fo:block font-weight="bold" space-after.optimum="1em">Peer-reviewed Publications</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:choose>
						<xsl:when
							test="(string-length($isAssociateProfessor) &gt; 0) or
							(string-length($isProfessor) &gt; 0)">
							<!-- filter out published abstracts -->
							<xsl:for-each
								select="personsPublications[peerReviewed='true' and (@xsi:type != 'publishedAbstract')]">
								<fo:table-row>
									<fo:table-cell>
										<fo:block text-align="end"><xsl:value-of select="position()"/>.</fo:block>
									</fo:table-cell>
									<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="citationFormat"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="personsPublications[peerReviewed='true' and (@xsi:type != 'publishedAbstract')]">
								<fo:table-row>
									<fo:table-cell>
										<fo:block  text-align="end"><xsl:value-of select="position()"/>.</fo:block>
									</fo:table-cell>
									<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="citationFormat"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-body>
			</fo:table>
		</xsl:if>
		<xsl:if
			test="count(personsPublications[peerReviewed='false' and (@xsi:type='reviewarticle' or translate(@xsi:type,$uc,$lc)='article' or translate(@xsi:type,$uc,$lc)='conferencepaper')])&gt;0">
			<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">Reviews, Proceedings of Conferences and Symposia (not peer-reviewed), Editorials</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each
						select="personsPublications[peerReviewed='false' and (translate(@xsi:type,$uc,$lc)='reviewarticle' or translate(@xsi:type,$uc,$lc)='article' or translate(@xsi:type,$uc,$lc)='conferencepaper')]">
						<fo:table-row>
							<fo:table-cell>
								<fo:block  text-align="end"><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="citationFormat"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
		<xsl:if
			test="count(personsPublications[translate(@xsi:type,$uc,$lc)='book' or translate(@xsi:type,$uc,$lc)='chapter'])&gt;0">
			<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">Books,
				Book Chapters, Monographs</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each
						select="personsPublications[translate(@xsi:type,$uc,$lc)='book' or translate(@xsi:type,$uc,$lc)='chapter']">
						<fo:table-row>
							<fo:table-cell>
								<fo:block text-align="end" ><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="citationFormat"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
		
		<xsl:if
			test="count(personsPublications[translate(@xsi:type,$uc,$lc)='poster' or translate(@xsi:type,$uc,$lc)='publishedabstract'])&gt;0">
			<xsl:choose>
				<xsl:when
					test="(string-length($isAssociateProfessor) &gt; 0) or
					(string-length($isProfessor) &gt; 0)">
					<!-- Do not include published abstracts if the person has a
						current position of "Associate Professor" or "Professor" -->
				</xsl:when>
				<xsl:otherwise>
					<fo:block  font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">Published Abstracts</fo:block>
					<fo:table xsl:use-attribute-sets="table">
						<fo:table-column column-width="0.45in"/>
						<fo:table-column column-width="0.05in"/>
						<fo:table-column column-width="6.00in"/>
						<fo:table-body>
							<xsl:for-each
								select="personsPublications[translate(@xsi:type,$uc,$lc)='poster' or translate(@xsi:type,$uc,$lc)='publishedabstract']">
								<fo:table-row>
									<fo:table-cell>
										<fo:block  text-align="end"><xsl:value-of select="position()"/>.</fo:block>
									</fo:table-cell>
									<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="citationFormat"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:if test="count(personsPublications[translate(@xsi:type,$uc,$lc)='otherpublication'])&gt;0">
			<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">Other
				Publications</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each
						select="personsPublications[translate(@xsi:type,$uc,$lc)='otherpublication']">
						<fo:table-row>
							<fo:table-cell>
								<fo:block text-align="end"><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="citationFormat"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitResearchItem">
		<fo:table xsl:use-attribute-sets="table">
			<fo:table-column column-width="2.0in"/>
			<fo:table-column column-width="4.5in"/>
			<fo:table-body>
				<xsl:if test="string-length(fundingSourceName) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Funding Agency:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="normalize-space(fundingSourceName)"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="string-length(grantOrContractNumber) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Grant Number:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="normalize-space(grantOrContractNumber)"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="string-length(projectTitle) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Title of Grant:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block text-transform="capitalize">
								<xsl:value-of select="normalize-space(projectTitle)"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="string-length(principalInvestigator) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Principal Investigator:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="normalize-space(principalInvestigator)"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="string-length(role) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>
								<!-- changed for vivo -->
								<xsl:choose>
									<xsl:when test="string-length(../person/familyName) &gt; 0">
										<xsl:value-of select="../person/familyName"/> 
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="../person/fullName"/> 
									</xsl:otherwise>
								</xsl:choose>Role on Grant:
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="normalize-space(role)"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if
					test="((dateRange/startDate/year != 0) and (dateRange/startDate/year != '')) 
					   or ((dateRange/endDate/year != 0) and (dateRange/endDate/year != '')) 
					   or (dateRange/endDate/present='true')">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Years Inclusive:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:call-template name="emitVitaDateRange">
									<xsl:with-param name="startDate" select="dateRange/startDate"/>
									<xsl:with-param name="endDate" select="dateRange/endDate"/>
									<xsl:with-param name="ignorePresent" select="'false'"/>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="(donatedEffort = 'true') or (percentSalaryCoverage &gt;0)">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Percent Effort:</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:choose>
									<xsl:when test="percentSalaryCoverage &gt;0">
										<xsl:value-of select="percentSalaryCoverage"/> % <xsl:if
											test="donatedEffort='true'"> (donated)</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="donatedEffort='true'">donated</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<!-- Convert the direct costs from scientific notation to a regular number -->
				<xsl:variable name="dca">
					<xsl:call-template name="convertSciToNumString">
						<xsl:with-param name="myval" select="directCostsAmount"/>
					</xsl:call-template>
				</xsl:variable>
				
				<!-- changed for vivo -->
				<xsl:choose>
					<xsl:when test="$dca &gt; 0">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>Total Direct Costs:</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:if test="$dca &gt; 0">$<xsl:value-of
											select="format-number($dca, '###,###,##0')"/></xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(directCostsAmount) &gt; 0">
							<fo:table-row>
								<fo:table-cell>
									<fo:block>Total Direct Costs:</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block>
										<xsl:value-of select="directCostsAmount"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:if>					
					</xsl:otherwise>				
				</xsl:choose>
						
				
				<!-- Convert the total amount from scientific notation to a number -->
				<xsl:variable name="ta">
					<xsl:call-template name="convertSciToNumString">
						<xsl:with-param name="myval" select="totalAmount"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- changed for vivo -->
				<xsl:choose>
					<xsl:when test="$ta &gt; 0">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>Total Amount Awarded:</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:if test="$ta &gt; 0"> $<xsl:value-of
											select="format-number($ta, '###,###,##0')"/></xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(totalAmount) &gt; 0">
							<fo:table-row>
								<fo:table-cell>
									<fo:block>Total Amount Awarded:</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><xsl:value-of select="totalAmount"/></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>

				<fo:table-row>
					<fo:table-cell>
						<fo:block>&#160;</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block/>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<!-- changed for vivo -->
	<xsl:template name="EmitResearch">
		<xsl:variable name="allResearch"
			select="personsFundings[awardStatus='Current' or awardStatus='Pending' or awardStatus='Complete' or awardStatus='']"/>
		<xsl:variable name="currentResearch" select="personsFundings[awardStatus='Current']"/>
		<xsl:variable name="pendingResearch" select="personsFundings[awardStatus='Pending']"/>
		<xsl:variable name="pastResearch" select="personsFundings[awardStatus='Complete']"/>
		<xsl:variable name="vivoResearch" select="personsFundings[awardStatus='']"/>

		<xsl:if test="count($allResearch)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt"
				space-after.optimum="1em">RESEARCH</fo:block>
			<xsl:if test="count($currentResearch)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Current research support</fo:block>
				<xsl:for-each select="$currentResearch">
					<xsl:call-template name="EmitResearchItem"/>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="count($pendingResearch)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Pending research support</fo:block>
				<xsl:for-each select="$pendingResearch">
					<xsl:call-template name="EmitResearchItem"/>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="count($pastResearch)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Past research support</fo:block>
				<xsl:for-each select="$pastResearch">
					<xsl:call-template name="EmitResearchItem"/>
				</xsl:for-each>
			</xsl:if>
			
			<xsl:if test="count($vivoResearch)&gt;0">
				<xsl:for-each select="$vivoResearch">
					<xsl:call-template name="EmitResearchItem"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template name="EmitPresentations">
		<xsl:variable name="invited" select="personsPresentations[invited='true']"/>
		<!-- changed for vivo shiyi-->
		<xsl:variable name="uninvited" select="personsPresentations[invited='false' or invited='']"/>

		<xsl:if test="count($invited)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em" space-before="20pt"
				space-after.optimum="1em">INVITED PRESENTATIONS</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>	
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each select="$invited">
						<fo:table-row>
							<fo:table-cell>
								<fo:block  text-align="end"><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="citationFormat"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>

		<xsl:if test="count($uninvited)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em"
				space-after.optimum="1em">OTHER PRESENTATIONS</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each select="$uninvited">
						<fo:table-row>
							<fo:table-cell>
								<fo:block text-align="end"><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="citationFormat"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitTeachingItems">
		<xsl:param name="teachingType"/>
		<xsl:param name="dataType"/>
	
		<xsl:if test="$teachingType='groupinstruction'">
			<xsl:variable name="data" select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and typeTaught=$dataType]"/>	
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="3.25in"/>
				<fo:table-column column-width="1.75in"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-weight="bold">Year(s)</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Course Number &amp; Title</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Role</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<xsl:for-each select="$data">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>
									<xsl:for-each select="orderedTeachingDates">
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate" select="startDate"/>
											<xsl:with-param name="endDate" select="endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
										<xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
									</xsl:for-each>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell padding-end="1em">
								<fo:block>
									<xsl:if test="string-length(courseNumber) &gt; 0"><xsl:value-of
											select="courseNumber"/>, </xsl:if>
									<xsl:value-of select="courseTitle"/>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:value-of select="normalize-space(role)"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
					
		<xsl:if test="$teachingType='otherteaching'">
			<xsl:variable name="data" select="personsActivities[translate(@xsi:type,$uc,$lc)='otherteaching']"/>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.30in"/>
				<fo:table-column column-width="1.50in"/>
				<fo:table-column column-width="2.20in"/>
				<fo:table-column column-width="1.75in"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-weight="bold">Year(s)</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Student Level</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Description</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Role</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<xsl:for-each select="$data">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>
									<xsl:for-each select="orderedTeachingDates">
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate" select="startDate"/>
											<xsl:with-param name="endDate" select="endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
										<xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
									</xsl:for-each>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block><xsl:value-of select="teachingLevel"/></fo:block>
							</fo:table-cell>
							<fo:table-cell padding-end="1em">
								<fo:block><xsl:value-of select="setting"/></fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:value-of select="normalize-space(role)"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
     	</xsl:if>
     	
     	<!-- added for vivo Teaching -->
     	<xsl:if test="$teachingType='vivoteaching'">
     		<xsl:variable name="data" select="personsActivities[translate(@xsi:type,$uc,$lc)='vivoteaching']"/>
     		<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="1.75in"/>
				<fo:table-column column-width="5.00in"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-weight="bold">Year(s)</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-weight="bold">Course Number &amp; Title</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<xsl:for-each select="$data">
						<fo:table-row>
							<fo:table-cell>
								<fo:block>
									<xsl:for-each select="orderedTeachingDates">
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate" select="startDate"/>
											<xsl:with-param name="endDate" select="endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
										<xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
									</xsl:for-each>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell padding-end="1em">
								<fo:block>
									<xsl:if test="string-length(courseNumber) &gt; 0"><xsl:value-of
											select="courseNumber"/>, </xsl:if>
									<xsl:value-of select="courseTitle"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
     	</xsl:if>

	</xsl:template>

	
	<xsl:template name="EmitTeaching">
		<!-- added for vivo Teaching -->
		<xsl:variable name="allTeaching"
			select="personsActivities[((translate(@xsi:type,$uc,$lc)='groupinstruction' or translate(@xsi:type,$uc,$lc)='otherteaching') 
			          and (typeTaught='Undergraduate' or typeTaught='Graduate' or typeTaught='Post-Graduate' or typeTaught='Postgraduate' or typeTaught='Predoctoral'))
			          or (translate(@xsi:type,$uc,$lc)='vivoteaching')]"/>
		
		<xsl:variable name="undergraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and typeTaught='Undergraduate']"/>
		<xsl:variable name="graduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and typeTaught='Graduate']"/>
		<xsl:variable name="postGraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and (typeTaught='Post-Graduate' or typeTaught='Postgraduate')]"/>
		<xsl:variable name="postDoctoral"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and typeTaught='Postdoctoral']"/>
		<xsl:variable name="precepting"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='otherteaching']"/>
		<xsl:variable name="preDoctoral"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='groupinstruction' and typeTaught='Predoctoral']"/>
		
		<!-- added for vivo Teaching -->
		<xsl:variable name="vivoTeaching"
		    select="personsActivities[translate(@xsi:type,$uc,$lc)='vivoteaching']" />
		
		<xsl:if test="count($allTeaching)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em"
				space-after.optimum="1em">TEACHING</fo:block>

			<xsl:if test="count($undergraduate)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Undergraduate Courses</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'groupinstruction'"/>
					<xsl:with-param name="dataType" select="'Undergraduate'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($graduate)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Graduate Courses</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'groupinstruction'"/>
					<xsl:with-param name="dataType" select="'Graduate'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($postGraduate)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Postgraduate Courses</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'groupinstruction'"/>
					<xsl:with-param name="dataType" select="'Post-Graduate'"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="count($preDoctoral)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Predoctoral Courses</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'groupinstruction'"/>
					<xsl:with-param name="dataType" select="'Predoctoral'"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="count($postDoctoral)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Postdoctoral Courses</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'groupinstruction'"/>
					<xsl:with-param name="dataType" select="'Postdoctoral'"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="count($precepting)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Precepting/Experiential</fo:block>
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'otherteaching'"/>
					<xsl:with-param name="dataType" select="''"/>
				</xsl:call-template>
			</xsl:if>
			
			<!-- added for vivo Teaching -->
			<xsl:if test="count($vivoTeaching)&gt;0">
				<xsl:call-template name="EmitTeachingItems">
					<xsl:with-param name="teachingType" select="'vivoteaching'"/>
					<xsl:with-param name="dataType" select="''"/>
				</xsl:call-template>
			</xsl:if>
			
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitAdvisingItemDetail">
		<xsl:param name="includeRole"/>

		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:call-template name="emitVitaDateRange">
						<xsl:with-param name="startDate" select="dateRange/startDate"/>
						<xsl:with-param name="endDate" select="dateRange/endDate"/>
						<xsl:with-param name="ignorePresent" select="'false'"/>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:value-of select="studentTraineeName"/>
				</fo:block>
				<fo:block>
					<xsl:value-of select="degreeAtEnd"/>
					<xsl:if test="string-length(degreeDate/year) != 0">
						<xsl:if test="degreeDate/year != 0"> (<xsl:if
								test="completeOrExpected='Expected'">expected
								</xsl:if><xsl:call-template name="VitaDateAsYMD">
								<xsl:with-param name="vitaDate" select="degreeDate"/>
								<xsl:with-param name="ignorePresent" select="'true'"/>
							</xsl:call-template>)</xsl:if>
					</xsl:if>
				</fo:block>
				<fo:block>
					<xsl:value-of select="topic"/>
				</fo:block>
			</fo:table-cell>
			<xsl:if test="$includeRole='true'">
				<fo:table-cell>
					<fo:block>
						<xsl:value-of select="facultyRole"/>
					</fo:block>
				</fo:table-cell>
			</xsl:if>
		</fo:table-row>

	</xsl:template>

	<xsl:template name="EmitAdvisingItems">
		<xsl:param name="dataType"/>
		<xsl:param name="includeRole"/>

		<xsl:variable name="undergraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='undergradstudent']"/>
		<xsl:variable name="mastersStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'masters' ]"/>
		<xsl:variable name="doctoralStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'doctoral']"/>
		<xsl:variable name="otherStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'other']"/>
		<xsl:variable name="postDoc"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='postdocorfellow']"/>
		<xsl:variable name="faculty"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='mentoringadvising']"/>
		<!-- added for vivo Mentoring and Advise -->
		<xsl:variable name="vivoGraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='vivograduate']" />
		<xsl:variable name="vivoOther"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='vivoother']" />
			
		<fo:table xsl:use-attribute-sets="table">
			<fo:table-column column-width="1.75in"/>
			<fo:table-column column-width="3.25in"/>
			<fo:table-column column-width="1.75in"/>

			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold">Year(s)</fo:block>
					</fo:table-cell>
					<xsl:choose>
						<xsl:when test="$includeRole='true'">
							<fo:table-cell>
								<fo:block font-weight="bold">
									<xsl:choose>
										<xsl:when test="$dataType='faculty'">Faculty Member's
											Name</xsl:when>
										<xsl:otherwise>Student's Name</xsl:otherwise>
									</xsl:choose> &amp; Degree/Discipline</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-weight="bold">Advisor's Role</fo:block>
							</fo:table-cell>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-cell number-columns-spanned="2">
								<fo:block font-weight="bold">
									<xsl:choose>
										<xsl:when test="$dataType='faculty'">Faculty Member's
											Name</xsl:when>
										<xsl:otherwise>Student's Name</xsl:otherwise>
									</xsl:choose> &amp; Degree/Discipline</fo:block>
							</fo:table-cell>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-row>

				<xsl:choose>
					<xsl:when test="$dataType='undergraduate'">
						<xsl:for-each select="$undergraduate">
						<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:when test="$dataType='mastersStudents'">
						<xsl:for-each select="$mastersStudents">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:when test="$dataType='otherStudents'">
						<xsl:for-each select="$otherStudents">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:when test="$dataType='doctoralStudents'">
						<xsl:for-each select="$doctoralStudents">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:when test="$dataType='postDoc'">
						<xsl:for-each select="$postDoc">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:when test="$dataType='faculty'">
						<xsl:for-each select="$faculty">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					
					<xsl:when test="$dataType='vivoGraduate'">
						<xsl:for-each select="$vivoGraduate">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					
					<xsl:when test="$dataType='vivoOther'">
						<xsl:for-each select="$vivoOther">
							<xsl:call-template name="EmitAdvisingItemDetail">
								<xsl:with-param name="includeRole" select="$includeRole"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>

			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template name="EmitAdvising">
		<xsl:variable name="allAdvising"
			select="personsActivities[(translate(@xsi:type,$uc,$lc)='undergradstudent') 
								   or (translate(@xsi:type,$uc,$lc)='gradstudent') 
								   or (translate(@xsi:type,$uc,$lc)='postdocorfellow') 
								   or (translate(@xsi:type,$uc,$lc)='mentoringadvising')
								   or (translate(@xsi:type,$uc,$lc)='vivograduate')
								   or (translate(@xsi:type,$uc,$lc)='vivoother')]"/>
		<xsl:variable name="undergraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='undergradstudent']"/>
		<xsl:variable name="mastersStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'masters' ]"/>
		<xsl:variable name="doctoralStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'doctoral' ]"/>
		<xsl:variable name="otherStudents"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='gradstudent' and translate(degreeType,$uc,$lc) = 'other' ]"/>
		<xsl:variable name="postDoc"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='postdocorfellow']"/>
		<xsl:variable name="faculty"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='mentoringadvising']"/>
		<!-- added for vivo Mentoring and Advise -->
		<xsl:variable name="vivoGraduate"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='vivograduate']" />
		<xsl:variable name="vivoOther"
			select="personsActivities[translate(@xsi:type,$uc,$lc)='vivoother']" />

		<xsl:if test="count($allAdvising)&gt;0">
			<fo:block font-weight="bold" text-align="center" space-before="20pt">MENTORING AND
				ADVISING</fo:block>
			<xsl:if test="count($undergraduate)">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Undergraduate Students</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'undergraduate'"/>
					<xsl:with-param name="includeRole" select="'true'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($mastersStudents)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Master's Students</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'mastersStudents'"/>
					<xsl:with-param name="includeRole" select="'true'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="count($doctoralStudents)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Doctoral Students</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'doctoralStudents'"/>
					<xsl:with-param name="includeRole" select="'true'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($otherStudents)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Other Students</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'otherStudents'"/>
					<xsl:with-param name="includeRole" select="'true'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($postDoc)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Postdoc or Fellow</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'postDoc'"/>
					<xsl:with-param name="includeRole" select="'false'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($faculty)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Mentored Faculty</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'faculty'"/>
					<xsl:with-param name="includeRole" select="'false'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="count($vivoGraduate)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Graduate Students</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'vivoGraduate'"/>
					<xsl:with-param name="includeRole" select="'false'"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="count($vivoOther)&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em"
					>Other</fo:block>
				<xsl:call-template name="EmitAdvisingItems">
					<xsl:with-param name="dataType" select="'vivoOther'"/>
					<xsl:with-param name="includeRole" select="'false'"/>
				</xsl:call-template>
			</xsl:if>

		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitService">
		<xsl:if
			test="count(personsActivities[(translate(@xsi:type,$uc,$lc)='committeemembership' 
										or translate(@xsi:type,$uc,$lc)='professionalpractice'
										or translate(@xsi:type,$uc,$lc)='publicpolicyprograms'
										or translate(@xsi:type,$uc,$lc)='otherscholarlyactivity'
										or translate(@xsi:type,$uc,$lc)='communityactivity'
										or translate(@xsi:type,$uc,$lc)='vivoservice')])&gt; 0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em" space-after.optimum="1em">SERVICE</fo:block>
			<xsl:call-template name="EmitCommittees"/>
			<xsl:call-template name="EmitExternalService"/>

			<xsl:if test="count(personsActivities[(translate(@xsi:type,$uc,$lc)='communityactivity') or (translate(@xsi:type,$uc,$lc)='otherscholarlyactivity')])&gt;0">
				<fo:block font-weight="bold" space-before.optimum="1em" space-after.optimum="1em">Other Professional Activities</fo:block>
				<fo:table xsl:use-attribute-sets="table">
					<fo:table-column column-width="1.75in"/>
					<fo:table-column column-width="5.0in"/>
					<fo:table-body>
						<xsl:for-each select="personsActivities[(translate(@xsi:type,$uc,$lc)='communityactivity') or (translate(@xsi:type,$uc,$lc)='otherscholarlyactivity')]">
							<fo:table-row>
								<fo:table-cell>
									<fo:block>
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate"
												select="dateRange/startDate"/>
											<xsl:with-param name="endDate"
												select="dateRange/endDate"/>
											<xsl:with-param name="ignorePresent" select="'false'"/>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block>
										<xsl:choose>
											<xsl:when test="string-length(role) &gt; 0">
												<xsl:value-of select="normalize-space(role)"/>
												<xsl:if test="string-length(description) &gt; 0">
												<xsl:text>, </xsl:text>
												<xsl:value-of
												select="normalize-space(description)"/>
												</xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(description)"
												/>
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</xsl:if>
			
			<xsl:if test="count(personsActivities[(translate(@xsi:type,$uc,$lc)='vivoservice')])&gt;0">
				<fo:table xsl:use-attribute-sets="table">
					<fo:table-column column-width="1.75in"/>
					<fo:table-column column-width="5.0in"/>
					<fo:table-body>
						<xsl:for-each select="personsActivities[(translate(@xsi:type,$uc,$lc)='vivoservice')]">
							<fo:table-row>
								<fo:table-cell>
									<fo:block>
										<xsl:call-template name="emitVitaDateRange">
											<xsl:with-param name="startDate"
												select="dateRange/startDate"/>
											<xsl:with-param name="endDate"
												select="dateRange/endDate"/>
											<xsl:with-param name="ignorePresent" select="'true'"/>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block>
										<xsl:choose>
											<xsl:when test="string-length(role) &gt; 0">
												<xsl:value-of select="normalize-space(role)"/>
												<xsl:if test="string-length(agency) &gt; 0">
												<xsl:text>, </xsl:text>
												<xsl:value-of select="normalize-space(agency)"/>
												</xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(agency)"
												/>
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</xsl:if>
			
		</xsl:if>
	</xsl:template>

	<xsl:template name="EmitPatents">
		<xsl:variable name="patents" select="personsPatents"/>
		<xsl:if test="count($patents) &gt; 0">
			<fo:block font-weight="bold" text-align="center" space-before.optimum="2em" space-before="20pt"
				space-after.optimum="1em">PATENTS</fo:block>
			<fo:table xsl:use-attribute-sets="table">
				<fo:table-column column-width="0.45in"/>
				<fo:table-column column-width="0.05in"/>
				<fo:table-column column-width="6.00in"/>
				<fo:table-body>
					<xsl:for-each select="$patents">
						<fo:table-row>
							<fo:table-cell>
								<fo:block text-align="end"><xsl:value-of select="position()"/>.</fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block  text-align="end"></fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:call-template name="CitePatent"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="DocumentIntermediateFormat">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
			<fo:layout-master-set>
				<fo:simple-page-master master-name="curriculum-vitae" page-width="8.5in" page-height="11in">
					<fo:region-body overflow="hidden" margin-bottom="0.5in" margin-right="0.5in" margin-left="0.75in" margin-top="1in"/>
					<fo:region-after extent=".5in" background-color="white" padding-left.length="1in"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="curriculum-vitae">
				<fo:static-content flow-name="xsl-region-after">
					<xsl:if test=" $targetFormat = 'pdf' ">
						<fo:table border-collapse="collapse">
							<fo:table-column column-width=".75in"/>
							<fo:table-column column-width="1.85in"/>
							<fo:table-column column-width="3.0in"/>
							<fo:table-column column-width="1.85in"/>
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell padding="0.2em">
										<fo:block></fo:block>
									</fo:table-cell>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="left">
											<xsl:copy-of select="$currentDate" />
											<!-- <xsl:value-of  select="substring(current-dateTime(),0,11)"/> --> 
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="center">
											<xsl:value-of select="person/givenName"/><xsl:text> </xsl:text>
											<xsl:value-of select="substring(person/middleNameOrInitial,1,1)"/><xsl:text> </xsl:text>
											<xsl:value-of select="person/familyName"/>
											<xsl:if test="count(personsTrainings/trainingDegree) &gt; 0">
												<xsl:text>, </xsl:text>
												<xsl:for-each select="personsTrainings/trainingDegree">
													<xsl:value-of select="."/>
													<xsl:if test="position()!=last()">, </xsl:if>
												</xsl:for-each>
											</xsl:if>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="right">
											<xsl:text>Page </xsl:text><fo:page-number/>
											of&#160;
											<fo:page-number-citation ref-id="last-page"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</xsl:if>
					<xsl:if test=" $targetFormat = 'rtf' ">
						<fo:table border-collapse="collapse">
							<fo:table-column column-width="2.0in"/>
							<fo:table-column column-width="3.0in"/>
							<fo:table-column column-width="2.0in"/>
							
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="left">
											<xsl:copy-of select="$currentDate" />
											<!-- <xsl:value-of  select="substring(current-dateTime(),0,11)"/> --> 
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="center">
											<xsl:value-of select="person/givenName"/><xsl:text> </xsl:text>
											<xsl:value-of select="substring(person/middleNameOrInitial,1,1)"/><xsl:text> </xsl:text>
											<xsl:value-of select="person/familyName"/>
											<xsl:if test="count(personsTrainings/trainingDegree) &gt; 0">
												<xsl:text>, </xsl:text>
												<xsl:for-each select="personsTrainings/trainingDegree">
													<xsl:value-of select="."/>
													<xsl:if test="position()!=last()">, </xsl:if>
												</xsl:for-each>
											</xsl:if>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding="0.2em" border-top-color="black"
										border-top-width="0.5pt" border-top-style="solid">
										<fo:block font-size="8pt" text-align="right">
											<xsl:text>Page </xsl:text><fo:page-number/>
											of&#160;
											<fo:page-number-citation ref-id="last-page"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</xsl:if>
				</fo:static-content>
				
				<fo:flow flow-name="xsl-region-body">
					<fo:wrapper font-family="{$documentFontType}" font-size="{$documentFontSize}">
						<xsl:call-template name="EmitHeader"/>
						<xsl:call-template name="EmitBiographicalInformation"/>
						<xsl:call-template name="EmitEducation"/>
						<xsl:call-template name="EmitAppointments"/>
						<xsl:call-template name="EmitLicenses"/>
						<xsl:call-template name="EmitMemberships"/>
						<xsl:call-template name="EmitAwards"/>
						<xsl:call-template name="EmitPublications"/>
						<xsl:call-template name="EmitResearch"/>
						<xsl:call-template name="EmitPeerReviewActivities"/>
						<xsl:call-template name="EmitPatents"/>
						<xsl:call-template name="EmitPresentations"/>
						<xsl:call-template name="EmitTeaching"/>
						<xsl:call-template name="EmitAdvising"/>
						<xsl:call-template name="EmitService"/>
						<fo:block id="last-page"/>
					</fo:wrapper>
				</fo:flow>
				

			</fo:page-sequence>
		</fo:root>
	</xsl:template>
</xsl:stylesheet>
