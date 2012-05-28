<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="fo">
	<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>
	<xsl:param name="citationFormat" select="'apa'"/> 
	<xsl:param name="documentFontType" select="'Helvetica'"/>
	<xsl:param name="documentFontSize" select="'11pt'"/>
	<xsl:param name="targetFormat" select="'pdf'"/>
	<xsl:param name="printOrElectronic" select="'print'"/>
	
	<xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	
		
	<xsl:template name="APAPublicationDate">
		<xsl:param name="pubDate"/>
		<xsl:if test="$pubDate/year &gt; 0"><xsl:value-of select="$pubDate/year"/>
			<xsl:if test="$pubDate/month &gt; 0"><xsl:text>, </xsl:text>
				<xsl:call-template name="MonthAsMMMM">
					<xsl:with-param name="monthNumber" select="$pubDate/month"/>
				</xsl:call-template>
				<xsl:if test="$pubDate/day &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="$pubDate/day"/></xsl:if></xsl:if>
		</xsl:if>
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
								<xsl:value-of select="$startDate/year"/><xsl:text> </xsl:text>
								<!-- conference starts & ends in the same month -->
								<xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template>
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<!-- show the day(s) -->
										<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/><xsl:if test="$endDate/day != 0"><xsl:if test="$endDate/day != $startDate/day"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/day"/></xsl:if></xsl:if><xsl:text> </xsl:text>
									</xsl:when>
								</xsl:choose>
								
							</xsl:when>
							
							<xsl:otherwise>
								<xsl:value-of select="$startDate/year"/><xsl:text> </xsl:text>
								<!-- conference starts & ends in different months -->
								<!-- Starting month -->
								<xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$startDate/month"/>
								</xsl:call-template>
								<!-- Starting day -->
								<xsl:choose>
									<xsl:when test="$startDate/day != 0">
										<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/>
									</xsl:when>
								</xsl:choose>
								<xsl:text>-</xsl:text><xsl:call-template name="MonthAsMMM">
									<xsl:with-param name="monthNumber" select="$endDate/month"/>
								</xsl:call-template>
								<xsl:if test="$endDate/day != 0">
									<xsl:text> </xsl:text><xsl:value-of select="$endDate/day"/>
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
								<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/><xsl:if test="$endDate/day != 0"><xsl:if test="$endDate/day != $startDate/day"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/day"/></xsl:if></xsl:if><xsl:text> </xsl:text>
							</xsl:when>
						</xsl:choose>
						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Start month not specified -->
				<xsl:choose>
					<!-- start year exist, end year may or may not exist -->
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
						<!-- start year doesn't exist, if end date exist, show up end date -->
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
					<xsl:when test="$vitaDate/month != 0"><xsl:text> </xsl:text><xsl:call-template name="MonthAsMMM">
						<xsl:with-param name="monthNumber" select="$vitaDate/month"/>
					</xsl:call-template><xsl:choose>
						<xsl:when test="$vitaDate/day != 0"><xsl:text> </xsl:text><xsl:value-of select="$vitaDate/day"/></xsl:when>
					</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
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
										<xsl:text> </xsl:text><xsl:value-of select="$startDate/day"/><xsl:if test="$endDate/day != 0"><xsl:if test="$endDate/day != $startDate/day"><xsl:text>-</xsl:text><xsl:value-of select="$endDate/day"/></xsl:if></xsl:if><xsl:text> </xsl:text>
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
	
	<xsl:template name="LeftPad">
		<xsl:param name="inString"/>
		<xsl:param name="targetLength"/>
		<xsl:param name="padWith"/>
		<xsl:choose>
			<xsl:when test="string-length($inString) &lt; $targetLength">
				<xsl:call-template name="LeftPad">
					<xsl:with-param name="targetLength" select="$targetLength"/>
					<xsl:with-param name="padWith" select="$padWith"/>
					<xsl:with-param name="inString" select="concat($padWith,$inString)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$inString"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="vitaDateAsMMYY">
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
								<!-- MM/YY Format -->
								<xsl:call-template name="LeftPad">
									<xsl:with-param name="padWith" select="'0'"/>
									<xsl:with-param name="targetLength" select="2"/>
									<xsl:with-param name="inString" select="$vitaDate/month"/>
								</xsl:call-template>/<xsl:value-of select="substring($vitaDate/year,3)"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- YY Format -->
								<xsl:value-of select="$vitaDate/year"/>
							</xsl:otherwise>
						</xsl:choose> 
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="vitaDateAsMMDDYY">
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
										<!-- MM/DD/YY Format -->
										<xsl:call-template name="LeftPad">
											<xsl:with-param name="padWith" select="'0'"/>
											<xsl:with-param name="targetLength" select="2"/>
											<xsl:with-param name="inString" select="$vitaDate/month"/>
										</xsl:call-template>/<xsl:call-template name="LeftPad">
											<xsl:with-param name="padWith" select="'0'"/>
											<xsl:with-param name="targetLength" select="2"/>
											<xsl:with-param name="inString" select="$vitaDate/day"/>
										</xsl:call-template>/<xsl:value-of select="substring($vitaDate/year,3)"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- MM/YY Format -->
										<xsl:call-template name="LeftPad">
											<xsl:with-param name="padWith" select="'0'"/>
											<xsl:with-param name="targetLength" select="2"/>
											<xsl:with-param name="inString" select="$vitaDate/month"/>
										</xsl:call-template>/<xsl:value-of select="substring($vitaDate/year,3)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!-- YY Format -->
								<xsl:value-of select="$vitaDate/year"/>
							</xsl:otherwise>
						</xsl:choose> 
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="emitMMDDYYDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>
		
		<xsl:variable name="dFrom"><xsl:call-template name="vitaDateAsMMDDYY">
			<xsl:with-param name="vitaDate" select="$startDate"/>
			<xsl:with-param name="ignorePresent" select="'true'"/>
		</xsl:call-template></xsl:variable>
		<xsl:variable name="dTo"><xsl:call-template name="vitaDateAsMMDDYY">
			<xsl:with-param name="vitaDate" select="$endDate"/>
			<xsl:with-param name="ignorePresent" select="$ignorePresent"/>
		</xsl:call-template></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($dFrom) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dFrom"/> - <xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$dFrom"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						N/A
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="emitMMYYDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>
		
		<xsl:variable name="dFrom"><xsl:call-template name="vitaDateAsMMYY">
			<xsl:with-param name="vitaDate" select="$startDate"/>
			<xsl:with-param name="ignorePresent" select="'true'"/>
		</xsl:call-template></xsl:variable>
		<xsl:variable name="dTo"><xsl:call-template name="vitaDateAsMMYY">
			<xsl:with-param name="vitaDate" select="$endDate"/>
			<xsl:with-param name="ignorePresent" select="$ignorePresent"/>
		</xsl:call-template></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($dFrom) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dFrom"/> - <xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$dFrom"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						N/A
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="emitVitaDateRange">
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		<xsl:param name="ignorePresent"/>
		
		<xsl:variable name="dFrom"><xsl:call-template name="VitaDateAsYMD">
			<xsl:with-param name="vitaDate" select="$startDate"/>
			<xsl:with-param name="ignorePresent" select="'true'"/>
		</xsl:call-template></xsl:variable>
		<xsl:variable name="dTo"><xsl:call-template name="VitaDateAsYMD">
			<xsl:with-param name="vitaDate" select="$endDate"/>
			<xsl:with-param name="ignorePresent" select="$ignorePresent"/>
		</xsl:call-template></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($dFrom) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dFrom"/> - <xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$dFrom"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($dTo) &gt; 0">
						<xsl:value-of select="$dTo"/>
					</xsl:when>
					<xsl:otherwise>
						N/A
					</xsl:otherwise>
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
										<xsl:value-of select="$vitaDate/month"/>/<xsl:value-of select="$vitaDate/day"/>/<xsl:value-of select="$vitaDate/year"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- M/YYYY Format -->
										<xsl:value-of select="$vitaDate/month"/>/<xsl:value-of select="$vitaDate/year"/>
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
	
	<xsl:template name="EmitAuthorList">
		<xsl:param name="targetName"/>
		<xsl:for-each select="node()[local-name()=$targetName]">
			<xsl:variable name="personName"><xsl:call-template name="EmitPerson"/></xsl:variable>
			<xsl:value-of select="normalize-space($personName)"/>			
			<xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
		</xsl:for-each>
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
					<xsl:variable name="personName"><xsl:call-template name="EmitPerson"/></xsl:variable>
					<xsl:value-of select="normalize-space($personName)"/><xsl:if test="position() != last()"><xsl:text>, </xsl:text><xsl:if test="(count(node()[local-name()=$targetName]) &gt; 1) and (position() = last()-1)"><xsl:text>&#38; </xsl:text></xsl:if></xsl:if>						
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

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
						<xsl:text> </xsl:text><xsl:value-of select="familyName"/>
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
	
	<xsl:template name="EmitStringWithDelimiter">
		<xsl:param name="inString"/>
		<xsl:param name="charList"/>
		<xsl:param name="delimeter"/>
		
		<xsl:variable name="nString" select="normalize-space($inString)"/>
		
		<xsl:if test="string-length($nString) &gt; 0">
			<xsl:variable name="lastChar" select="substring($nString, string-length($nString), 1)"/>
			<xsl:value-of select="$nString"/><xsl:if test="not(contains($charList, $lastChar))"><xsl:value-of select="$delimeter"/></xsl:if><xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="EmitTitle">
		<xsl:param name="title"/>
		<xsl:if test="string-length($title) &gt; 0">
			<xsl:variable name="lastChar" select="substring(normalize-space($title), string-length(normalize-space($title)), 1)"/>
			<xsl:value-of select="normalize-space($title)"/>
			<xsl:if test="($lastChar != '!') and ($lastChar != '?') and ($lastChar != '.')">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="CiteJournalArticle">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:if test="count(contributors) &gt; 0"><xsl:text>.  </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template>
				<!-- Journal Title -->
				<xsl:if test="string-length(journalTitle) &gt; 0">
					<xsl:value-of select="normalize-space(journalTitle)"/><xsl:text>.  </xsl:text>
				</xsl:if>
				<xsl:variable name="pubDate"><xsl:call-template name="emitCitationVitaDate">
						<xsl:with-param name="vitaDate" select="publicationDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
				</xsl:call-template></xsl:variable>
				<xsl:variable name="pvi"><xsl:call-template name="CitePageVolumeIssue"/></xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">
					<xsl:value-of select="normalize-space($pubDate)"/>
					<xsl:if test="string-length(normalize-space($pvi)) &gt; 0">
						<xsl:text>; </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:value-of select="$pvi"/>
			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="publicationDate/year != 0">(<xsl:call-template name="APAPublicationDate"><xsl:with-param name="pubDate" select="publicationDate"/></xsl:call-template>).<xsl:text> </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template>				
				<xsl:if test="string-length(journalTitle) &gt; 0">
					<xsl:text> </xsl:text>
					<fo:inline font-style="italic"><xsl:value-of select="normalize-space(journalTitle)"/></fo:inline>
				</xsl:if>
				<xsl:if test="volume &gt; 0">
					<xsl:text>, </xsl:text><xsl:value-of select="normalize-space(volume)"/>
					<xsl:if test="issue &gt; 0">(<xsl:value-of select="normalize-space(issue)"/>)</xsl:if>
				</xsl:if>
				<xsl:if test="string-length(pages) &gt; 0">
					<xsl:text>, </xsl:text><xsl:value-of select="normalize-space(pages)"/>
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
				</xsl:call-template><xsl:if test="count(contributors) &gt; 0"><xsl:text>.  </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="title"/>
				</xsl:call-template>
				
				<!-- Edition -->
				<xsl:if test="edition &gt; 0">
					<xsl:call-template name="nthFormatNumber">
						<xsl:with-param name="num" select="edition"/>
					</xsl:call-template>
					<xsl:if test="edition &gt; 1">
						rev<xsl:text>.  </xsl:text>
					</xsl:if>
					ed<xsl:text>.  </xsl:text>
				</xsl:if>
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
						<xsl:if test="publicationDate/year != 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publicationDate/year)"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
						<xsl:if test="publicationDate/year != 0"><xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text></xsl:if><xsl:value-of select="normalize-space(year)"/></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:variable name="pubDate"><xsl:call-template name="emitAPACitationVitaDate">
					<xsl:with-param name="vitaDate" select="publicationDate"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">(<xsl:value-of
					select="normalize-space($pubDate)"/>)<xsl:text>. </xsl:text></xsl:if>
				
				<!-- Title -->
				<xsl:if test="string-length(title) &gt; 0"><fo:inline font-style="italic"><xsl:value-of select="normalize-space(title)"/></fo:inline>
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
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
						<xsl:if test="publicationDate/year != 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publicationDate/year)"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
						<xsl:if test="publicationDate/year != 0"><xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text></xsl:if><xsl:value-of select="normalize-space(year)"/></xsl:if>
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
				</xsl:call-template><xsl:if test="count(contributors) &gt; 0"><xsl:text>.  </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:if test="string-length(title)">
					<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template>
				</xsl:if>
				<!-- Book Title -->
				<xsl:if test="string-length(bookTitle) &gt; 0">
					In:<xsl:text> </xsl:text>
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
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
						<xsl:if test="publicationDate/year != 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publicationDate/year)"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
						<xsl:if test="publicationDate/year != 0"><xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text></xsl:if><xsl:value-of select="normalize-space(year)"/></xsl:if>
					</xsl:otherwise>
				</xsl:choose><xsl:text>.  </xsl:text>
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0"><xsl:value-of select="normalize-space(pages)"/></xsl:if>
			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:variable name="pubDate"><xsl:call-template name="emitAPACitationVitaDate">
					<xsl:with-param name="vitaDate" select="publicationDate"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($pubDate) &gt; 0">(<xsl:value-of
					select="normalize-space($pubDate)"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:if test="string-length(title) &gt; 0"><xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="presentationTitle"/></xsl:call-template>
					<xsl:if test="string-length(edition) &gt; 0"><xsl:text> </xsl:text>(<xsl:call-template name="nthFormatNumber">
						<xsl:with-param name="num" select="edition"/>
					</xsl:call-template> rev. ed.)<xsl:text>.  </xsl:text>
					</xsl:if>
				</xsl:if>
				<!-- Book Title -->
				<xsl:if test="string-length(bookTitle) &gt; 0">
					In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1"><xsl:text> (Eds.), </xsl:text></xsl:if>
						<xsl:if test="count(editors) = 1"><xsl:text> (Ed.), </xsl:text></xsl:if>							
					</xsl:if>
					<fo:inline font-style="italic">
						<xsl:call-template name="EmitTitle">
							<xsl:with-param name="title" select="bookTitle"/>
						</xsl:call-template>
					</fo:inline>
					<!-- Pages -->
					<xsl:if test="string-length(pages) &gt; 0">(<xsl:value-of select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				</xsl:if>
				
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="CitePresentation">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:variable name="authors"><xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'authors'"/>
				</xsl:call-template></xsl:variable><xsl:if test="string-length($authors) &gt; 0"><xsl:value-of select="$authors"/><xsl:if test="substring($authors,string-length($authors),1) != '.'">.</xsl:if><xsl:text>  </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="presentationTitle"/></xsl:call-template>
				
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">
					Paper presented at: <xsl:value-of select="normalize-space(meetingName)"/>
				</xsl:if>
				
				<!-- Dates -->
				<xsl:variable name="mDates"><xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length($mDates) &gt; 0">
					<xsl:if test="string-length(meetingName) &gt; 0">
						<xsl:text>; </xsl:text>
					</xsl:if>
					<xsl:value-of select="$mDates"/>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:if test="(string-length(meetingName) &gt; 0) or (string-length($mDates) &gt; 0)">
						<xsl:text>; </xsl:text>
					</xsl:if>
				<xsl:value-of select="normalize-space(meetingLocation)"/></xsl:if>
			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:variable name="authors"><xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'authors'"/>
				</xsl:call-template></xsl:variable><xsl:if test="string-length($authors) &gt; 0"><xsl:value-of select="$authors"/><xsl:if test="substring($authors,string-length($authors),1) != '.'">.</xsl:if><xsl:text>  </xsl:text></xsl:if>
				<!-- Year -->
				<xsl:variable name="mDates"><xsl:call-template name="emitCitationVitaDateRange">
						<xsl:with-param name="startDate" select="meetingDates/startDate"/>
						<xsl:with-param name="endDate" select="meetingDates/endDate"/>
						<xsl:with-param name="ignorePresent" select="'true'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length(mDates) &gt; 0">
					(<xsl:value-of select="mDates"/>)<xsl:text>. </xsl:text>
				</xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle">
					<xsl:with-param name="title" select="presentationTitle"/>
				</xsl:call-template>
				
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">
					Paper presented at <xsl:value-of select="normalize-space(meetingName)"/>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="normalize-space(meetingLocation)"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CiteOtherPublication">
		<xsl:if test="string-length(citation) &gt; 0">
			<xsl:value-of select="normalize-space(citation)"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="CitePublishedAbstract">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:if test="count(contributors) &gt; 0"><xsl:text>.  </xsl:text></xsl:if>
				<!-- Paper Title -->
				<xsl:if test="string-length(title) &gt; 0">
					<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="presentationTitle"/></xsl:call-template> [abstract]
				</xsl:if>
				<!-- Proceedings Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0">
					In:<xsl:text> </xsl:text>
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
					<xsl:value-of select="normalize-space(conferenceTitle)"/><xsl:text>; </xsl:text>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates"><xsl:call-template name="emitCitationVitaDateRange">
					<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
					<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
					<xsl:with-param name="ignorePresent" select="'true'"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0"><xsl:value-of select="$cDates"/><xsl:text>. </xsl:text> </xsl:if>
				<!-- Conference Location -->
				<xsl:call-template name="EmitStringWithDelimiter">
					<xsl:with-param name="inString" select="conferenceLocation"/>
					<xsl:with-param name="charList" select="'.?!'"/>
					<xsl:with-param name="delimeter" select="'.'"/>
				</xsl:call-template>
				
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
						<xsl:if test="publicationDate/year != 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publicationDate/year)"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
						<xsl:if test="publicationDate/year != 0"><xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text></xsl:if><xsl:value-of select="normalize-space(year)"/></xsl:if>
					</xsl:otherwise>
				</xsl:choose><xsl:text>. </xsl:text>
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0"><xsl:value-of select="normalize-space(pages)"/></xsl:if>
			</xsl:when>
			
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="publicationDate/year != 0">(<xsl:value-of select="normalize-space(publicationDate/year)"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:if test="string-length(title) &gt; 0"><xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template> [abstract]<xsl:text>.  </xsl:text></xsl:if>
				<!-- Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0">
					In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1"><xsl:text> (Eds.), </xsl:text></xsl:if>
						<xsl:if test="count(editors) = 1"><xsl:text> (Ed.), </xsl:text></xsl:if>
					</xsl:if>
					<fo:inline font-style="italic">
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="proceedingsBookTitle"/>
					</xsl:call-template></fo:inline>
				</xsl:if>
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<fo:inline font-style="italic"><xsl:value-of select="normalize-space(conferenceTitle)"/><xsl:text>, </xsl:text></fo:inline>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(conferenceLocation) &gt; 0">
					<xsl:text>; </xsl:text><xsl:value-of select="normalize-space(conferenceLocation)"/><xsl:text>,  </xsl:text>
				</xsl:if>
				<!-- Conference Dates -->
				<xsl:variable name="cDates"><xsl:call-template name="emitCitationVitaDateRange">
					<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
					<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
					<xsl:with-param name="ignorePresent" select="'true'"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0"><xsl:value-of select="$cDates"/><xsl:text> </xsl:text></xsl:if>
				
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0">(<xsl:value-of select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>						
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="CitePoster">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:variable name="authors"><xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'authors'"/>
				</xsl:call-template></xsl:variable><xsl:value-of select="$authors"/><xsl:if test="substring($authors,string-length($authors),1) != '.'">.</xsl:if><xsl:text>  </xsl:text>
				<!-- Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="presentationTitle"/></xsl:call-template>
				
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Poster session presented at: <xsl:value-of select="normalize-space(meetingName)"/></xsl:if>
				<!-- Year -->
				<xsl:if test="meetingDates/startDate/year != 0"><xsl:text>; </xsl:text><xsl:value-of select="meetingDates/startDate/year"/></xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0"><xsl:text>; </xsl:text><xsl:value-of select="normalize-space(meetingLocation)"/></xsl:if>
				
			</xsl:when>
			<xsl:when test="$citationFormat='apa'">
				<!-- Authors -->
				<xsl:variable name="authors"><xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'authors'"/>
				</xsl:call-template></xsl:variable><xsl:value-of select="$authors"/><xsl:if test="substring($authors,string-length($authors),1) != '.'">.</xsl:if><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="meetingDates/startDate/year != 0">(<xsl:value-of select="meetingDates/startDate/year"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="presentationTitle"/></xsl:call-template>
				
				<!-- Conference name -->
				<xsl:if test="string-length(meetingName) &gt; 0">Poster session presented at <xsl:value-of select="normalize-space(meetingName)"/></xsl:if>
				<!-- Conference Location -->
				<xsl:if test="string-length(meetingLocation) &gt; 0"><xsl:text>, </xsl:text><xsl:value-of select="normalize-space(meetingLocation)"/></xsl:if>
				
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="CitePageNumbers">
		<xsl:param name="pCitation"/><xsl:if test="string-length($pCitation) &gt; 0"><xsl:text> </xsl:text><xsl:if test="not(contains($pCitation, 'p'))"></xsl:if><xsl:value-of select="$pCitation"/></xsl:if>
	</xsl:template>
	
	<xsl:template name="CiteConferencePaper">
		<xsl:choose>
			<xsl:when test="$citationFormat='vancouver'">
				<!-- Authors -->
				<xsl:call-template name="EmitAuthorList">
					<xsl:with-param name="targetName" select="'contributors'"/>
				</xsl:call-template><xsl:text>.  </xsl:text>
				<!-- Paper Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template>
				
				<!-- Proceedings Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0">
					In:<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>, editor<xsl:if test="count(editors) &gt; 1">s</xsl:if><xsl:text>.  </xsl:text>
					</xsl:if>
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="proceedingsBookTitle"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Conference Title -->
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<xsl:value-of select="normalize-space(conferenceTitle)"/><xsl:text>; </xsl:text>
				</xsl:if>
				<xsl:variable name="cDates"><xsl:call-template name="emitCitationVitaDateRange">
					<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
					<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
					<xsl:with-param name="ignorePresent" select="'true'"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length(normalize-space($cDates)) &gt; 0"><xsl:value-of select="normalize-space($cDates)"/><xsl:text>; </xsl:text></xsl:if>				
				
				<!-- Conference Location -->
				<xsl:call-template name="EmitStringWithDelimiter">
					<xsl:with-param name="inString" select="conferenceLocation"/>
					<xsl:with-param name="charList" select="'.?!'"/>
					<xsl:with-param name="delimeter" select="'.'"/>
				</xsl:call-template>
				
				<!-- Publication Location -->
				<xsl:variable name="pubDate"><xsl:call-template name="emitCitationVitaDate">
					<xsl:with-param name="vitaDate" select="publicationDate"/>
				</xsl:call-template></xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/></xsl:if>
						<xsl:if test="string-length($pubDate) != 0"><xsl:text>, </xsl:text><xsl:value-of select="$pubDate"/><xsl:text>. </xsl:text></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/></xsl:if>
						<xsl:if test="string-length($pubDate) != 0"><xsl:if test="string-length(publisher) &gt; 0"><xsl:text>, </xsl:text></xsl:if><xsl:value-of select="$pubDate"/><xsl:text>. </xsl:text></xsl:if>
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
				</xsl:call-template><xsl:text>  </xsl:text>
				<!-- Year -->
				<xsl:if test="string-length(year) &gt; 0">(<xsl:value-of select="normalize-space(year)"/>)<xsl:text>. </xsl:text></xsl:if>
				<!-- Chapter Title -->
				<xsl:call-template name="EmitTitle"><xsl:with-param name="title" select="title"/></xsl:call-template>

				<!-- Book Title -->
				<xsl:if test="string-length(proceedingsBookTitle) &gt; 0">
					In<xsl:text> </xsl:text>
					<xsl:if test="count(editors) &gt; 0">
						<xsl:call-template name="EmitEditorList">
							<xsl:with-param name="targetName" select="'editors'"/>
						</xsl:call-template>
						<xsl:if test="count(editors) &gt; 1"><xsl:text> (Eds.), </xsl:text></xsl:if>
						<xsl:if test="count(editors) = 1"><xsl:text> (Ed.), </xsl:text></xsl:if>
					</xsl:if>
					<fo:inline font-style="italic">
					<xsl:call-template name="EmitTitle">
						<xsl:with-param name="title" select="bookTitle"/>
					</xsl:call-template></fo:inline>
				</xsl:if>
				<xsl:if test="string-length(conferenceTitle) &gt; 0">
					<fo:inline font-style="italic"><xsl:value-of select="normalize-space(conferenceTitle)"/><xsl:text>, </xsl:text></fo:inline>
				</xsl:if>
				<!-- Conference Location -->
				<xsl:call-template name="EmitStringWithDelimiter">
					<xsl:with-param name="inString" select="conferenceLocation"/>
					<xsl:with-param name="charList" select="'.?!'"/>
					<xsl:with-param name="delimeter" select="'.'"/>
				</xsl:call-template>
				
				<!-- Conference Dates -->
				APACD!
				<xsl:variable name="cDates"><xsl:call-template name="emitAPACitationVitaDateRange">
					<xsl:with-param name="startDate" select="conferenceDates/startDate"/>
					<xsl:with-param name="endDate" select="conferenceDates/endDate"/>
					<xsl:with-param name="ignorePresent" select="'true'"/>
				</xsl:call-template></xsl:variable>
				<xsl:if test="string-length($cDates) &gt; 0"><fo:inline font-style="italic"><xsl:value-of select="$cDates"/><xsl:text> </xsl:text></fo:inline></xsl:if>
				
				<!-- Pages -->
				<xsl:if test="string-length(pages) &gt; 0">(<xsl:value-of select="normalize-space(pages)"/>)<xsl:text>.  </xsl:text></xsl:if>
				<!-- Publication Location -->
				<xsl:choose>
					<xsl:when test="string-length(publicationLocation) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length(publisher) &gt; 0">
								<xsl:variable name="pubName"><xsl:value-of select="normalize-space(publicationLocation)"/></xsl:variable>
								<xsl:choose>
									<xsl:when test="substring($pubName, string-length($pubName),1) = '.'">
										<xsl:value-of select="substring($pubName, 1, string-length($pubName)-1)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pubName"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/>;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(publicationLocation)"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(publisher)"/></xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length(publisher) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(publisher)"/></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="citationFormat">
		<xsl:variable name="citation"><xsl:choose>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='article'">
				<xsl:call-template name="CiteJournalArticle"/>
			</xsl:when>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='book'">
				<xsl:call-template name="CiteBook"/>
			</xsl:when>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='otherpublication'">
				<xsl:call-template name="CiteOtherPublication"/>
			</xsl:when>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='chapter'">
				<xsl:call-template name="CiteBookChapter"/>
			</xsl:when>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='publishedabstract'">
				<xsl:call-template name="CitePublishedAbstract"/>
			</xsl:when>
			<xsl:when test="translate(@xsi:type,$uc,$lc)='conferencepaper'">
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
		<xsl:if test="publicationStatus='accepted'"> (accepted)</xsl:if>
		<xsl:if test="invited='true'"> (invited)</xsl:if></xsl:variable>
		<xsl:variable name="ncite" select="normalize-space($citation)"/>
		<xsl:variable name="lastChar" select="substring($ncite, string-length($ncite), 1)"/>
		<xsl:value-of select="normalize-space($ncite)"/><xsl:if test="($lastChar != '!') and ($lastChar != '?') and ($lastChar != '.')"><xsl:text>. </xsl:text></xsl:if>
		<xsl:if test="string-length(pubMedCentralID) &gt; 0"><xsl:text>PMCID: </xsl:text><xsl:value-of select="normalize-space(pubMedCentralID)"/></xsl:if>
	</xsl:template>

	<!--  ERR 11/19/08 BEGIN -->

	<xsl:template name="emitContributor">
		<xsl:if test="$citationFormat = 'apa'">
			<xsl:value-of select="normalize-space(familyName)"/>
			<xsl:choose>
				<xsl:when test="string-length(givenName) &gt; 0">
					<xsl:choose>
						<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
							<xsl:text>, </xsl:text><xsl:value-of select="substring(givenName, 1, 1)"/><xsl:text>. </xsl:text><xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/><xsl:text>.</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>, </xsl:text><xsl:value-of select="substring(givenName, 1, 1)"/><xsl:text>.</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
							<xsl:text>, </xsl:text><xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/><xsl:text>.</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:if test="$citationFormat = 'vancouver'">
			<xsl:value-of select="normalize-space(familyName)"/>
			<xsl:choose>
				<xsl:when test="string-length(givenName) &gt; 0">
					<xsl:choose>
						<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
							<xsl:text> </xsl:text><xsl:value-of select="substring(givenName, 1, 1)"/><xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> </xsl:text><xsl:value-of select="substring(givenName, 1, 1)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(middleNameOrInitial) &gt; 0">
							<xsl:text> </xsl:text><xsl:value-of select="substring(middleNameOrInitial, 1, 1)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<!--  ERR 11/19/08 END -->

	

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

	<xsl:template name="EmitEducationInformation">
		<fo:table border-collapse="collapse">
			<fo:table-column column-width="3.0in"/>
			<fo:table-column column-width="1.25in"/>
			<fo:table-column column-width="1.25in"/>
			<fo:table-column column-width="2in"/>
			
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-bottom-color="black" border-bottom-width="0.5pt"
						border-bottom-style="solid" border-right-color="black"
						border-right-width="0.5pt" border-right-style="solid">
						<fo:block font-size="8pt" text-align="center">INSTITUTION AND LOCATION</fo:block>
					</fo:table-cell>
					
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-bottom-color="black" border-bottom-width="0.5pt"
						border-bottom-style="solid" border-right-color="black"
						border-right-width="0.5pt" border-right-style="solid">
						<fo:block font-size="8pt"  text-align="center">DEGREE </fo:block>
						<fo:block font-size="8pt"  text-align="center">(if applicable)</fo:block>
					</fo:table-cell>
					
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-bottom-color="black" border-bottom-width="0.5pt"
						border-bottom-style="solid" border-right-color="black"
						border-right-width="0.5pt" border-right-style="solid">
						<fo:block font-size="8pt"  text-align="center">MM/YY</fo:block>
					</fo:table-cell>
					
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-bottom-color="black" border-bottom-width="0.5pt"
						border-bottom-style="solid">
						<fo:block font-size="8pt" text-align="center">FIELD OF STUDY</fo:block>
					</fo:table-cell>
					
				</fo:table-row>
				
				<xsl:for-each select="personsTrainings">
					<xsl:choose>
					<xsl:when test="position() != last()">
					
					<fo:table-row>
					<fo:table-cell padding="0.2em" border-right-color="black" 	border-right-width="0.5pt" border-right-style="solid">
							<fo:block>
								<!-- ERR 11/12/08 - added call to 'Implode' function -->
								<xsl:call-template name="implode">
									<xsl:with-param name="values"
										select="institution | location"/>
									<xsl:with-param name="format"
										select="'institution,location'"/>
									<xsl:with-param name="delimiter"
										select="', '"/>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em" border-right-color="black" 	border-right-width="0.5pt" border-right-style="solid">
							<fo:block text-align="center">
								<xsl:for-each select="trainingDegree">
									<xsl:value-of select="."/><xsl:if test="position()!=last()">, </xsl:if>
								</xsl:for-each>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em" border-right-color="black" border-right-width="0.5pt" border-right-style="solid">
							<fo:block text-align="center">
								<xsl:choose>
									<xsl:when test="(count(trainingDegree) &gt; 0) and (dateOfDegree/year != 0)">
										<xsl:choose>
											<xsl:when test="(string-length(dateOfDegree/month) &gt; 0) and (dateOfDegree/month &gt; 0)">
												<xsl:call-template name="LeftPad">
													<xsl:with-param name="padWith" select="'0'"/>
													<xsl:with-param name="targetLength" select="2"/>
													<xsl:with-param name="inString" select="dateOfDegree/month"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>??</xsl:otherwise>
										</xsl:choose>/<xsl:value-of select="substring(dateOfDegree/year,3)"/>
									</xsl:when>
									<!-- <xsl:otherwise>
										<xsl:for-each
											select="orderedTrainingDates">
												<fo:block>
													<xsl:call-template name="emitMMYYDateRange">
														<xsl:with-param name="startDate" select="startDate"/>
														<xsl:with-param name="endDate" select="endDate"/>
														<xsl:with-param name="ignorePresent" select="'false'"/>
													</xsl:call-template>
												</fo:block>	
										</xsl:for-each>
									</xsl:otherwise> -->
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em">
							<fo:block>
								<xsl:value-of select="discipline"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					</xsl:when>
					
					<xsl:otherwise>
					<fo:table-row>
					<fo:table-cell padding="0.2em"  border-bottom-color="black" 			
						border-bottom-width="0.5pt" border-bottom-style="solid"
						border-right-color="black" border-right-width="0.5pt" 	border-right-style="solid">
							<fo:block>
								<!-- ERR 11/12/08 - added call to 'Implode' function -->
								<xsl:call-template name="implode">
									<xsl:with-param name="values"
										select="institution | location"/>
									<xsl:with-param name="format"
										select="'institution,location'"/>
									<xsl:with-param name="delimiter"
										select="', '"/>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em" border-bottom-color="black"
						border-bottom-width="0.5pt" border-bottom-style="solid"
						border-right-color="black" border-right-width="0.5pt" border-right-style="solid">
							<fo:block text-align="center">
								<xsl:for-each select="trainingDegree">
									<xsl:value-of select="."/><xsl:if test="position()!=last()">, </xsl:if>
								</xsl:for-each>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em" border-bottom-color="black"
						border-bottom-width="0.5pt" border-bottom-style="solid"
						border-right-color="black" border-right-width="0.5pt" border-right-style="solid">
							<fo:block text-align="center">
								<xsl:choose>
									<xsl:when test="(count(trainingDegree) &gt; 0) and (dateOfDegree/year != 0)">
										<xsl:choose>
											<xsl:when test="(string-length(dateOfDegree/month) &gt; 0) and (dateOfDegree/month &gt; 0)">
												<xsl:call-template name="LeftPad">
													<xsl:with-param name="padWith" select="'0'"/>
													<xsl:with-param name="targetLength" select="2"/>
													<xsl:with-param name="inString" select="dateOfDegree/month"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>??</xsl:otherwise>
										</xsl:choose>/<xsl:value-of select="substring(dateOfDegree/year,3)"/>
									</xsl:when>
									<!-- <xsl:otherwise>
										<xsl:for-each
											select="orderedTrainingDates">
												<fo:block>
													<xsl:call-template name="emitMMYYDateRange">
														<xsl:with-param name="startDate" select="startDate"/>
														<xsl:with-param name="endDate" select="endDate"/>
														<xsl:with-param name="ignorePresent" select="'false'"/>
													</xsl:call-template>
												</fo:block>	
										</xsl:for-each>
									</xsl:otherwise> -->
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
						
						<fo:table-cell padding="0.2em" border-bottom-color="black" border-bottom-width="0.5pt" border-bottom-style="solid">
							<fo:block>
								<xsl:value-of select="discipline"/>
							</fo:block>
						</fo:table-cell>
						
					</fo:table-row>
					</xsl:otherwise>
			  </xsl:choose>
			</xsl:for-each>
				
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template name="EmitNameTitleERAC">
		<fo:table border-collapse="collapse">
			<fo:table-column column-width="3.0in"/>
			<fo:table-column column-width="4.5in"/>
			
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell padding="0.2em" number-columns-spanned="2"
						border-top-color="black" border-top-width="0.5pt"
						border-top-style="solid" padding-top="0.5em">
						<fo:block font-weight="bold" text-align="center" font-size="12pt">BIOGRAPHICAL SKETCH</fo:block>
						<fo:block text-align="center" font-size="8pt"
							>Provide the following information for the key personnel and other significant contributors in the order listed on Form Page 2. Follow this format for each person.  DO NOT EXCEED FOUR PAGES.</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell number-columns-spanned="2"
						border-top-color="black" border-top-width="0.5pt"
						border-top-style="solid">
						<fo:block>&#160;</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-right-color="black" border-right-width="0.5pt"
						border-right-style="solid">
						<fo:block font-size="8pt">NAME</fo:block>
						<fo:block>
							<xsl:value-of select="person/familyName"/>
							<xsl:choose>
								<xsl:when test="string-length(person/givenName) &gt; 0">
									<xsl:text>, </xsl:text>
									<xsl:value-of select="person/givenName"/>
									<xsl:if test="string-length(person/middleNameOrInitial) &gt; 0">
										<xsl:text> </xsl:text>
										<xsl:value-of select="person/middleNameOrInitial"/>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="string-length(person/middleNameOrInitial) &gt; 0">
										<xsl:text>, </xsl:text>
										<xsl:value-of select="person/middleNameOrInitial"/>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>			
						</fo:block>
					</fo:table-cell>
					
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid">
						<fo:block font-size="8pt">POSITION TITLE</fo:block>
						<fo:block>
							<xsl:for-each
								select="personsProfessionalPositions[primaryPosition = 'true']">
								<xsl:if test="position() = 1">
									<!-- ERR 11/10/08 - added call to 'Implode' function -->
									<xsl:call-template name="implode">
										<xsl:with-param name="values"
											select="title | department | institution"/>
										<xsl:with-param name="format"
											select="'title,department,institution'"/>
										<xsl:with-param name="delimiter"
											select="', '"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:for-each>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				
				<fo:table-row>
					<fo:table-cell padding="0.2em" border-top-color="black"
						border-top-width="0.5pt" border-top-style="solid"
						border-right-color="black" border-right-width="0.5pt"
						border-right-style="solid">
						<fo:block font-size="8pt">eRA COMMONS USER NAME</fo:block>
						<fo:block><xsl:value-of select="person/ERACommonsUsername"
						/>&#160;</fo:block>
					</fo:table-cell>
					<fo:table-cell padding="0.2em">
						<fo:block>&#160;</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row>
					<fo:table-cell padding="0.2em" number-columns-spanned="2"
						border-top-color="black" border-top-width="0.5pt"
						border-top-style="solid" border-bottom-color="black"
						border-bottom-width="0.5pt" border-bottom-style="solid">
						<fo:block font-size="8pt"
							>EDUCATION/TRAINING  (Begin with baccalaureate or other initial professional education, such as nursing, and include postdoctoral training.)</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<xsl:template name="EmitHeaderTables">
		<xsl:call-template name="EmitNameTitleERAC"></xsl:call-template>
		<xsl:call-template name="EmitEducationInformation"></xsl:call-template>
	</xsl:template>

	<xsl:template name="EmitPersonalStatement">
		<fo:block font-size="11pt" font-weight="bold" space-before=".5em">A. Personal Statement</fo:block>
		<fo:block font-weight="normal" space-before=".5em">
			<xsl:value-of select="//personalStatements/statement"/>
		</fo:block>
	</xsl:template>

	<xsl:template name="EmitPositionsAndHonors">
		<fo:block font-size="11pt" font-weight="bold" space-before=".5em">B. Positions and Honors</fo:block>
		
		<xsl:choose>
			<xsl:when test="count(personsProfessionalPositions) + count(personsActivities) + count(personsHonors) &gt; 0">
				<xsl:if test="count(personsProfessionalPositions)&gt;0">
					<fo:block font-size="11pt" font-weight="bold" text-decoration="underline" space-before=".5em" space-after=".5em">Positions and Employment</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5.75in"/>
						<fo:table-body>
							<xsl:for-each select="personsProfessionalPositions">
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
											<!-- ERR 11/12/08 - added call to 'Implode' function -->
											<xsl:call-template name="implode">
												<xsl:with-param name="values"
													select="title | department | institution | location"/>
												<xsl:with-param name="format"
													select="'title,department,institution,location'"/>
												<xsl:with-param name="delimiter"
													select="', '"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
				
				<xsl:if test="count(personsActivities[(translate(@xsi:type,$uc,$lc)='communityactivity' 
													or translate(@xsi:type,$uc,$lc)='committeemembership' 
													or translate(@xsi:type,$uc,$lc)='profsocietymembership' 
													or translate(@xsi:type,$uc,$lc)='editorialboard' 
													or translate(@xsi:type,$uc,$lc)='manuscriptreview' 
													or translate(@xsi:type,$uc,$lc)='grantproposalreview' 
													or translate(@xsi:type,$uc,$lc)='conferencematerialsreview' 
													or translate(@xsi:type,$uc,$lc)='otherreviewactivity'
													or translate(@xsi:type,$uc,$lc)='professionalpractice'
													or translate(@xsi:type,$uc,$lc)='publicpolicyprograms'
													or translate(@xsi:type,$uc,$lc)='otherscholarlyactivity')])&gt;0">
					<fo:block font-size="11pt" font-weight="bold" text-decoration="underline" space-before=".5em" space-after=".5em">Other Experience and Professional Memberships</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5.75in"/>
						<fo:table-body>
							<xsl:for-each select="personsActivities">
								<xsl:if test="translate(@xsi:type,$uc,$lc)='conferencematerialsreview'">
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
											<fo:block><xsl:value-of select="role"
											/>, <xsl:value-of select="normalize-space(meetingDescription)"
											/></fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='manuscriptreview'">
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
											<fo:block><xsl:value-of select="role"
											/>, <xsl:value-of select="normalize-space(journalName)"
											/></fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='grantproposalreview'">
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
											<fo:block><xsl:value-of select="role"
											/>, <xsl:value-of select="normalize-space(agencyName)"
											/></fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='editorialboard'">
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
												<xsl:value-of select="role" />, Editorial Board, <xsl:value-of select="normalize-space(journalName)"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='otherreviewactivity'">
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
												<xsl:value-of select="role" />, <xsl:value-of select="normalize-space(description)"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>

								<xsl:if test="translate(@xsi:type,$uc,$lc)='committeemembership'">
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
											<fo:block><xsl:value-of select="committeeName"/>
												<xsl:if test="string-length(role) &gt; 0">, <xsl:value-of select="role"/></xsl:if> 
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='professionalpractice'">
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
												<xsl:value-of select="role"/>, <xsl:value-of select="normalize-space(description)"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='publicpolicyprograms'">
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
												<xsl:value-of select="role"/>, <xsl:value-of select="normalize-space(description)"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
															
								<xsl:if test="translate(@xsi:type,$uc,$lc)='profsocietymembership'">
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
												<xsl:if test="role!=''"><xsl:value-of
													select="role"/>, </xsl:if>
												<xsl:value-of select="societyName"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:if test="translate(@xsi:type,$uc,$lc)='communityactivity' or translate(@xsi:type,$uc,$lc)='otherscholarlyactivity'">
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
														<xsl:if test="string-length(description) &gt; 0">
														<xsl:text>, </xsl:text>
														<xsl:value-of select="normalize-space(description)"/>
														</xsl:if>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="normalize-space(description)"/>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
				
				<xsl:if test="count(personsHonors)&gt;0">
					<fo:block font-size="11pt" font-weight="bold" text-decoration="underline" space-before=".5em" space-after=".5em">Honors</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="1.75in"/>
						<fo:table-column column-width="5.75in"/>
						<fo:table-body>
							<xsl:for-each select="personsHonors">
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
											<xsl:value-of select="title"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="12pt" margin-left="2em" space-before=".5em">None</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitPeerReviewedPublications">
		<fo:block font-size="11pt" font-weight="bold" space-before=".5em">C. Selected peer-reviewed publications</fo:block>
		<xsl:choose>
			<xsl:when test="count(personsPublications) &gt; 0">
				<xsl:if test="count(personsPublications[group='relevant'])&gt;0">
					<fo:block font-size="11pt" text-decoration="underline" font-weight="bold" space-before=".5em" space-after=".5em"
						>Most relevant to the current application</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="0.25in"/>
						<fo:table-column column-width="7.25in"/>
						<fo:table-body>
							<xsl:for-each select="personsPublications[group='relevant']">
								<fo:table-row>
									<fo:table-cell>
										<fo:block><xsl:value-of select="position()"/>.</fo:block>
									</fo:table-cell>
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
				
				<xsl:if test="count(personsPublications[not(group)])&gt;0">
					<fo:block font-size="11pt" text-decoration="underline" font-weight="bold" space-before=".5em" space-after=".5em"
						>Additional recent publications of importance to the field (in chronological order)</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="0.25in"/>
						<fo:table-column column-width="7.25in"/>
						<fo:table-body>
							<xsl:for-each select="personsPublications[not(group)]">
								<fo:table-row>
									<fo:table-cell>
										<fo:block><xsl:value-of select="position()"/>.</fo:block>
									</fo:table-cell>
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
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="12pt" margin-left="2em" space-before=".5em">None</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="EmitResearchSupport">
		<fo:block font-size="11pt" font-weight="bold" space-before=".5em">D. Research Support</fo:block>
		<xsl:choose>
			<xsl:when  test="count(personsFundings) &gt; 0">
				<xsl:if test="count(personsFundings[awardStatus='Current'])&gt;0">
					<fo:block font-size="11pt" font-weight="bold" text-decoration="underline" space-before=".5em">On-going Research Support</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="4in"/>
						<fo:table-column column-width="3.5in"/>
						<fo:table-body>
							<xsl:for-each select="personsFundings[awardStatus='Current']">
								<fo:table-row>
									<fo:table-cell  number-columns-spanned="2">
										<fo:block font-size="0.5em">&#160;</fo:block>
									</fo:table-cell>
								</fo:table-row>								
								<fo:table-row >
									<fo:table-cell>
										<fo:block ><xsl:value-of select="grantOrContractNumber" />&#160;
										<xsl:if test="principalInvestigator!=''">(<xsl:value-of select="normalize-space(principalInvestigator)"/>)</xsl:if>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="emitMMDDYYDateRange">
												<xsl:with-param name="startDate" select="dateRange/startDate"/>
												<xsl:with-param name="endDate" select="dateRange/endDate"/>
												<xsl:with-param name="ignorePresent" select="'false'"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								
								<fo:table-row>
									<fo:table-cell number-columns-spanned="2">
										<xsl:if test="fundingSourceName!=''">
											<fo:block>
												<xsl:value-of select="fundingSourceName"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="projectTitle!=''">
											<fo:block>
												<xsl:value-of select="projectTitle"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="description!=''">
											<fo:block>
												<xsl:value-of select="description"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="role!=''">
											<fo:block>Role: <xsl:value-of select="role"/></fo:block>
										</xsl:if>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
								
				<xsl:if test="count(personsFundings[awardStatus='Complete'])&gt;0">
					<fo:block font-size="11pt" font-weight="bold" text-decoration="underline"
						space-before=".5em">Completed Research Support</fo:block>
					<fo:table border-collapse="collapse">
						<fo:table-column column-width="4in"/>
						<fo:table-column column-width="3.5in"/>
						<fo:table-body>
							<xsl:for-each select="personsFundings[awardStatus='Complete']">
								<fo:table-row>
									<fo:table-cell  number-columns-spanned="2">
										<fo:block font-size="0.5em">&#160;</fo:block>
									</fo:table-cell>
								</fo:table-row>									
								<fo:table-row>
									<fo:table-cell>
										<fo:block><xsl:value-of select="grantOrContractNumber" />&#160;
										<xsl:if test="principalInvestigator!=''">(<xsl:value-of select="principalInvestigator"/>)</xsl:if>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:call-template name="emitMMDDYYDateRange">
												<xsl:with-param name="startDate" select="dateRange/startDate"/>
												<xsl:with-param name="endDate" select="dateRange/endDate"/>
												<xsl:with-param name="ignorePresent" select="'false'"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								
								<fo:table-row>
									<fo:table-cell number-columns-spanned="2">
										<xsl:if test="fundingSourceName!=''">
											<fo:block>
												<xsl:value-of select="fundingSourceName"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="projectTitle!=''">
											<fo:block>
												<xsl:value-of select="projectTitle"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="description!=''">
											<fo:block>
												<xsl:value-of select="description"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="role!=''">
											<fo:block>Role: <xsl:value-of select="role"/></fo:block>
										</xsl:if>
									</fo:table-cell>
								</fo:table-row>									
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="12pt" margin-left="2em" space-before=".5em" >None</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/DocumentIntermediateFormat">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

			<fo:layout-master-set>
				<fo:simple-page-master master-name="nih-biosketch" page-width="8.5in" page-height="11in">
					<fo:region-body overflow="hidden" margin-bottom="0.5in" margin-right="0.5in" margin-left="0.5in" margin-top="0.5in"/>
					<fo:region-before extent=".5in"  background-color="white" padding-left.length="1in"/>
					<fo:region-after extent=".5in" background-color="white" padding-left.length="1in"/>
				</fo:simple-page-master>
			</fo:layout-master-set>

			<fo:page-sequence master-reference="nih-biosketch">
				<fo:static-content flow-name="xsl-region-before">
					<xsl:choose>
					<xsl:when test="$printOrElectronic = 'print' ">
						<xsl:if test=" $targetFormat = 'pdf' ">
							<fo:block text-align="left" margin-top=".25in" font-size="8pt" margin-left=".5in">
								Program Director/Principal Investigator (Last, First, Middle): 
							</fo:block>
						</xsl:if>
						<xsl:if test=" $targetFormat = 'rtf' ">
							<fo:block text-align="left" margin-top=".25in" font-size="8pt">
								Program Director/Principal Investigator (Last, First, Middle): 
							</fo:block>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<fo:block></fo:block>
					</xsl:otherwise>
					</xsl:choose>
				</fo:static-content>
				
				<fo:static-content flow-name="xsl-region-after">
					<xsl:choose>
						<xsl:when test="$printOrElectronic = 'print' ">
							<xsl:if test=" $targetFormat = 'pdf' ">
							
							<fo:table border-collapse="collapse">
								<fo:table-column column-width=".5in"/>
								<fo:table-column column-width="2.0in"/>
								<fo:table-column column-width="3.25in"/>
								<fo:table-column column-width="2.0in"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell padding="0.2em">
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="left">PHS 398/2590(Rev.06/09)</fo:block>
										</fo:table-cell>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="center">
											Page <fo:page-number/> of &#160;<fo:page-number-citation ref-id="last-page"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="right"></fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
							</xsl:if>
							<xsl:if test=" $targetFormat = 'rtf' ">
							<fo:table border-collapse="collapse">
								<fo:table-column column-width="2.0in"/>
								<fo:table-column column-width="3.25in"/>
								<fo:table-column column-width="2.0in"/>
								
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="left">PHS 398/2590(Rev.06/09)</fo:block>
										</fo:table-cell>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="center">
											Page <fo:page-number/> of &#160;<fo:page-number-citation ref-id="last-page"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell padding="0.2em" border-top-color="black"
											border-top-width="0.5pt" border-top-style="solid">
											<fo:block font-size="8pt" text-align="right"></fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<fo:block></fo:block>
						</xsl:otherwise>
					</xsl:choose>
				</fo:static-content>
				
				<fo:flow flow-name="xsl-region-body">
					<fo:wrapper font-family="{$documentFontType}" font-size="{$documentFontSize}">
						<xsl:call-template name="EmitHeaderTables"/>
						<xsl:call-template name="EmitPersonalStatement"/>
						<xsl:call-template name="EmitPositionsAndHonors"/>
						<xsl:call-template name="EmitPeerReviewedPublications"/>
						<xsl:call-template name="EmitResearchSupport"/>
						<fo:block id="last-page"/>
					</fo:wrapper>
				</fo:flow>
				

			</fo:page-sequence>
		</fo:root>
	</xsl:template>
</xsl:stylesheet>
