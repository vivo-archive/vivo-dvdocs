prefix vivo: <http://vivoweb.org/ontology/core#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix bibo: <http://purl.org/ontology/bibo/>
prefix classes: <http://vitro.mannlib.cornell.edu/ns/cornell/stars/classes#>
prefix hr: 	  <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#>
prefix public: <http://vitro.mannlib.cornell.edu/ns/vitro/public#>
prefix event: <http://purl.org/NET/c4dm/event.owl#>
prefix ThomsonWOS: <http://vivo.mannlib.cornell.edu/ns/ThomsonWOS/0.1#>
prefix osp: <http://vivoweb.org/ontology/cu-vivo-osp#>
prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
prefix ns: <http://vivo.library.cornell.edu/ns/0.1#>
prefix mannadditions: <http://vivo.cornell.edu/ns/mannadditions/0.1#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix ai: <http://vivoweb.org/ontology/activity-insight#>
prefix portal: <http://www.aktors.org/ontology/portal#>
prefix lib: <http://vivo.library.cornell.edu/ns/0.1#>

declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
declare variable $graph external;
declare variable $personId external;

declare function local:emptyString($arg){
	let $x :=
	if(string-length($arg) > 0) then ", "
	else ()
	return $x	
};

declare function local:getAdviseeType($address){
	let $x :=
	if(matches($address,"GraduateStudent"))then "vivoGraduate"
	else if(matches($address,"UndergradStudent"))then "UndergradStudent"
	else if(matches($address,"Postdoc"))then "PostdocOrFellow"
	else if(matches($address,"FacultyMember"))then "MentoringAdvising"
	else "vivoOther"
	return $x
};

declare function local:returnDay($type, $date){
	let $x :=
    if(string-length($date)>11) then
    	if(contains($type, 'yearMonthDayTimePrecision') or contains($type, 'yearMonthDayPrecision')) then day-from-dateTime($date)
    	else ()
    else
    	if(contains($type, 'yearMonthDayTimePrecision') or contains($type, 'yearMonthDayPrecision')) then day-from-date($date)
    	else ()
    return $x
};

declare function local:returnMonth($type, $date){
	let $zero := ""
	let $x :=
    if(string-length($date)>11) then
    	if(contains($type, 'yearPrecision')) then $zero
    	else month-from-dateTime($date)
    else
    	if(contains($type, 'yearPrecision')) then $zero
    	else month-from-date($date) 
    return $x
};

declare function local:returnYear($date){
	let $x :=
    if(string-length($date)>11) then year-from-dateTime($date)
    else year-from-date($date) 
    return $x
};

declare function local:returnDate($type, $date, $startOrEnd){
	let $x :=
	if($startOrEnd = 'startDate') then
		<startDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</startDate>

	else if($startOrEnd = 'endDate') then
		<endDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</endDate>
		
	else if($startOrEnd = 'issueDate') then
		<issueDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</issueDate>

	else if($startOrEnd = 'expirationDate') then
		<expirationDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</expirationDate>
		
	else if($startOrEnd = 'publicationDate') then
		<publicationDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</publicationDate>
		
	else if($startOrEnd = 'dateOfDegree') then
		<dateOfDegree>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</dateOfDegree>
		
	else if($startOrEnd = 'applicationDate') then
		<applicationDate>
			<day>{local:returnDay($type,$date)}</day>
			<month>{local:returnMonth($type,$date)}</month>
			<sortDate>{$date}</sortDate>				
			<year>{local:returnYear($date)}</year>
		</applicationDate>		
	
	else ()
	return $x
};


let $false := "false"
let $true := "true"

return

{for * from $graph
 where {$person a foaf:Person}
 return 
 
 {if(contains($person,$personId)) then
   <DocumentIntermediateFormat>
   
   {for * from $graph
	where {{{$person foaf:lastName $familyName ; foaf:firstName $givenName}
		     union {$person rdfs:label $fullName}}
		   optional {$person vivo:middleName $middleName}
		  }limit 1
	return 
		<person>
        	<ERACommonsUsername></ERACommonsUsername>
        	<familyName>{$familyName}</familyName>
        	<givenName>{$givenName}</givenName>
        	<fullName>{$fullName}</fullName>
        	<middleNameOrInitial>{substring($middleName, 1, 1)}</middleNameOrInitial>
		</person>
	}
	
	{for * from $graph
	 where {$person vivo:primaryEmail $email}
	 return
    	<personsEmailContacts>
			<emailAddress>{$email}</emailAddress>
        	<use>business</use>
    	</personsEmailContacts>
	}	
	
	 
	{for * from $graph
	 where {$person vivo:personInPosition $personInPosition .
	 		$personInPosition a vivo:Position .
	 		$personInPosition vivo:positionInOrganization $inOrgnization
	 		optional {$personInPosition vivo:dateTimeInterval $positionDate . $positionDate vivo:start $start . 
	 				  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
	 		optional {$personInPosition vivo:dateTimeInterval $positionDate . $positionDate vivo:end $end . 
	 				  $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}	    	       		 	
	 		}
	 order by $startDate
	 return
	 	<personsProfessionalPositions>		 		
	 		<academic>
	 		{for * from $graph
	 		 where {$personInPosition a vivo:NonAcademicPosition}
	 		 return {$false}
	 		}</academic>
	 				 					
	 		{for * from $graph
	 		 where {$inOrgnization vivo:subOrganizationWithin $subOrganizationWithin . 
	 		 		$subOrganizationWithin rdfs:label $institution		 
	 		 	   }
	 		 return
	 		 	<institution>{$institution}</institution>
	 		}
	 			 		
        	{for * from $graph
        	 where {{$personInPosition rdfs:label $title} union {$personInPosition vivo:hrJobTitle $title}}
	 		 return
        		<title>{$title}</title>
        	 }
			
			{for * from $graph
			 where {$inOrgnization rdfs:label $school}limit 1
			 return
				<school>{$school}</school>
			}
			
			<location></location>
	    	<dateRange>
	    		{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}	    			 	         
	    	</dateRange>		
    	</personsProfessionalPositions>
	 } 
	 
	 {for * from $graph
	  where {$person vivo:hasCredential $license .
			  {{$license a vivo:Certification} union {$license a vivo:Licensure}} .
		      optional {$license rdfs:label $description}
		      optional {$license vivo:issuanceOfCredential $issuanceOfCredential . 
		      			$issuanceOfCredential vivo:hasGoverningAuthority $hasGoverningAuthority . 
		      			$hasGoverningAuthority rdfs:label $grantingAuthority}
		      optional {$license vivo:licenseNumber $licenseNumber}
		      optional {$license vivo:expirationDate $dateexpirted . 
		        		$dateexpirted vivo:dateTime $expirationDate . $dateexpirted vivo:dateTimePrecision $expirationType}
		      optional {$license vivo:dateIssued $dateIssued . 
		        		$dateIssued vivo:dateTime $issueDate . $dateIssued vivo:dateTimePrecision $issueType}		       
		      }
	  order by $issueDate
	  return
		 	<personsLicenseOrCertificates>
		 		<specialty>vivoLicenses</specialty>
		 		<grantingAuthority>{$grantingAuthority}</grantingAuthority>
		 		<licenseNumber>{$licenseNumber}</licenseNumber>
		 		<type>{$description}</type>
		 		{local:returnDate($issueType, $issueDate, 'issueDate')}
		 		{local:returnDate($expirationType, $expirationDate, 'expirationDate')}		   				   		
		 	</personsLicenseOrCertificates>
	 }
		
   	  
	{for * from $graph
	 where {$person vivo:awardOrHonor $awardOrHonor . 
	 		$awardOrHonor rdfs:label $honor .
	 		optional {$awardOrHonor vivo:dateTimeValue $dateTimeValue . 
	 				  $dateTimeValue vivo:dateTime $dateTime . $dateTimeValue vivo:dateTimePrecision $type}
	 		optional {$awardOrHonor vivo:awardConferredBy $awardConferredBy . $awardConferredBy rdfs:label $organization}
	 		}
	 return
	 	<personsHonors>
	 		<dateRange>{local:returnDate($type, $dateTime, 'startDate')}</dateRange>
	 		<title>{$honor}{local:emptyString($organization)}{$organization}</title>
    	</personsHonors>
	}
	
	{for * from $graph
	 where {$person vivo:hasServiceProviderRole $service . 
	 	    optional {$service rdfs:label $role}	 	    
	 	    optional {$service vivo:roleIn $roleIn . $roleIn rdfs:label $agency}
	 	    optional {$service vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:start $start . 
	 	    		  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
 			optional {$service vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:end $end . 
 					  $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}
			}
	 order by $startDate
	 return
    	<personsActivities xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="vivoService">
			<agency>{$agency}</agency>
        	<role>{$role}</role>
        	<dateRange>
				{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}
        	</dateRange>
    	</personsActivities>
	}

	{for * from $graph
	 where {$person vivo:educationalTraining $educationalTraining . 
	 		optional {$educationalTraining vivo:majorField $majorField}	 		
	 		optional {$educationalTraining vivo:degreeEarned $degreeEarned . $degreeEarned rdfs:label $degree}
	 		optional {$educationalTraining vivo:hasGeogaphicLocation $hasGeogaphicLocation . $hasGeogaphicLocation rdfs:label $location}
	 		optional {$educationalTraining vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:end $end . 
	 				  $end vivo:dateTime $dateOfDegree . $end vivo:dateTimePrecision $dateOfDegreeType}
	 		}
	order by $dateOfDegree
	return
		<personsTrainings>
			<discipline>{$majorField}</discipline>
			{for * from $graph
			 where {$educationalTraining vivo:trainingAtOrganization $trainingAtOrganization . 
	 				$trainingAtOrganization rdfs:label $organization . 
	 				optional {$educationalTraining vivo:departmentOrSchool $departmentOrSchool}
	 				}
	 	     return
	 	     	<institution>{$departmentOrSchool}{local:emptyString($departmentOrSchool)}{$organization}</institution>			
			}

        	<trainingDegree>{$degree}</trainingDegree>
        	<location>{$location}</location>       	
        	<trainingLevel>vivoTraining</trainingLevel>
        	{local:returnDate($dateOfDegreeType, $dateOfDegree, 'dateOfDegree')}
		</personsTrainings>	
	}
	
	{for * from $graph
	 where {$person vivo:hasCo-PrincipalInvestigatorRole $inGrant . 
	 		$inGrant vivo:roleIn $grant . $grant a vivo:Grant .
	 		$grant rdfs:label $projectTitle .
	 		optional {$grant vivo:grantAwardedBy $grantAwardedBy . $grantAwardedBy rdfs:label $fundingSourceName}
	 		optional {$grant vivo:sponsorAwardId $sponsorAwardId}
 			optional {$grant bibo:abstract $abstract}
 			optional {$grant vivo:grantDirectCosts $directCosts}
 			optional {$grant vivo:totalAwardAmount $totalAwardAmount}			
 			optional {$inGrant vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:start $start . 
 					  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
 			optional {$inGrant vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:end $end . 
 					  $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}
	 		}
	 order by $startDate
	 return
	    <personsFundings>
	    	<projectTitle>{lower-case($projectTitle)}</projectTitle>
	        <fundingSourceName>{$fundingSourceName}</fundingSourceName>
	        <grantOrContractNumber>{$sponsorAwardId}</grantOrContractNumber>	        
	        <description>{$abstract}</description>
	        <awardStatus></awardStatus>
	        <role>Co-Principal Investigator</role>
	        <directCostsAmount>{$directCosts}</directCostsAmount>
	        <totalAmount>{$totalAwardAmount}</totalAmount>
	        <dateRange>
				{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}
	    	</dateRange>	
	        	        
	        {for * from $graph
	         where {$grant vivo:relatedRole $relatedRole . 
	         	    $relatedRole vivo:co-PrincipalInvestigatorRoleOf $principleInvestigators
	         	    optional {$principleInvestigators foaf:lastName $principleInvestigatorsLN ;  foaf:firstName $principleInvestigatorsFN}
	         	    }
	         return
	         	<principalInvestigator>{concat($principleInvestigatorsFN , " ", $principleInvestigatorsLN)}</principalInvestigator>
	        }
	             	        	        	       	     	        
	    </personsFundings>
	}
	
	{for * from $graph
	 where {$person vivo:hasPrincipalInvestigatorRole $inGrant . 
	 		$inGrant vivo:roleIn $grant . $grant a vivo:Grant .
	 		$grant rdfs:label $projectTitle .
	 		optional {$grant vivo:grantAwardedBy $grantAwardedBy . $grantAwardedBy rdfs:label $fundingSourceName}
	 		optional {$grant vivo:sponsorAwardId $sponsorAwardId}
 			optional {$grant bibo:abstract $abstract}
 			optional {$grant vivo:grantDirectCosts $directCosts}
 			optional {$grant vivo:totalAwardAmount $totalAwardAmount}
 			optional {$grant vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:start $start . 
 					  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
 			optional {$grant vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:end $end . 
 					  $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}
	 		}
	 order by $startDate
	 return
	    <personsFundings>
	    	<projectTitle>{lower-case($projectTitle)}</projectTitle>
	        <fundingSourceName>{$fundingSourceName}</fundingSourceName>
	        <grantOrContractNumber>{$sponsorAwardId}</grantOrContractNumber>	        
	        <description>{$abstract}</description>
	        <awardStatus></awardStatus>
	        <role>Principal Investigator</role>
	        <directCostsAmount>{$directCosts}</directCostsAmount>
	        <totalAmount>{$totalAwardAmount}</totalAmount>
	        <dateRange>
				{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}
	    	</dateRange>	
	        
	        {for * from $graph
	         where {$grant vivo:relatedRole $relatedRole . 
	         	    $relatedRole vivo:principalInvestigatorRoleOf $principleInvestigators
	         	    optional {$principleInvestigators foaf:lastName $principleInvestigatorsLN ;  foaf:firstName $principleInvestigatorsFN}
	         	    }
	         return
	         	<principalInvestigator>{concat($principleInvestigatorsFN , " ", $principleInvestigatorsLN)}</principalInvestigator>
	        }
	             	        	        	       	     	        
	    </personsFundings>
	}
	 
		{for * from $graph
		 where {$person vivo:authorInAuthorship $authorInAuthorship . 
		   	    $authorInAuthorship vivo:linkedInformationResource $patent .
		   		$patent a bibo:Patent . 
		   		$patent rdfs:label $patentTitle .
		   		optional {$patent vivo:patentNumber $patentNumber}
		   		optional {$patent vivo:dateFiled $dateFiled . 
		   				  $dateFiled vivo:dateTime $applicationDate . $dateFiled vivo:dateTimePrecision $fileType}
		   		optional {$patent vivo:dateIssued $dateIssued . 
		   				  $dateIssued vivo:dateTime $issueDate . $dateIssued vivo:dateTimePrecision $issueType}
		   		}
		 return
		   	<personsPatents>
		   		<title>{$patentTitle}</title>
		   		<patentOrApplicationNumber>{$patentNumber}</patentOrApplicationNumber>
		   		{local:returnDate($fileType, $applicationDate, 'applicationDate')}
				{local:returnDate($issueType, $issueDate, 'issueDate')}
		   		
		   		{for * from $graph
	             where{$patent vivo:informationResourceInAuthorship $contribAuthorship .
	                   $contribAuthorship vivo:linkedAuthor $author } 
	             return
	                 {for * from $graph
	                  where {$author foaf:lastName $authorLN ;  foaf:firstName $authorFN .
	                         optional {$contribAuthorship vivo:authorRank $authorRank} 
	                         optional {$author rdfs:label $authorDN} 
	                         optional {$author vivo:middleName $authorMN}
	                          }
	                   order by $authorRank
	                   return
	                      <contributors>                           	  
	                        <givenName>{$authorFN}</givenName>
	                        <familyName>{$authorLN}</familyName>
	                        <displayName>{$authorDN}</displayName>
	                        <middleNameOrInitial>{substring($authorMN, 1, 1)}</middleNameOrInitial>
	                        <positionInSequence>{$authorRank}</positionInSequence>
	                       </contributors>
	                   }
	               }
		  	</personsPatents>
		 }
	
		{for * from $graph
		 where {$person vivo:advisorIn $advisorIn . 
		 		$advisorIn a vivo:AdvisingRelationship . 
		 		$advisorIn vivo:advisee $advisee .
        		optional {$advisee rdfs:label $studentName}
	 	    	optional {$advisee vivo:educationalTraining $educationalTraining . 
	 	    			  $educationalTraining vivo:degreeEarned $degreeEarned . $degreeEarned vivo:abbreviation $degreeAtEnd}
	 	    	optional {$advisee vitro:mostSpecificType $mostSpecificType}
	 	    	optional {$advisorIn vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:start $start . 
	 	    			  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
 				optional {$advisorIn vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:end $end . 
 						  $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}
		 		}
		 order by $startDate
		 return
		     <personsActivities xsi:type="{local:getAdviseeType($mostSpecificType)}">     		
        		<studentTraineeName>{$studentName}</studentTraineeName>      		        		        		
        		<topic></topic>
        		<degreeAtEnd>{$degreeAtEnd}</degreeAtEnd>
        		<degreeDate>
        			<day></day>
		            <month></month>
		            <present>{$false}</present>
		            <sortDate></sortDate>
		            <year></year>
        		</degreeDate>
        		<completeOrExpected></completeOrExpected>
        		
        		<dateRange>
					{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}
        		</dateRange>
    		</personsActivities>				
		}
		
	
	{for * from $graph
	 where {$person vivo:hasPresenterRole $hasPresenterRole .
	 		$hasPresenterRole vivo:roleIn $presentation . 
	 		
	 		optional {$presentation rdf:type bibo:Conference . $presentation rdfs:label $meetingName}
	 		optional {$presentation rdf:type vivo:Presentation . $presentation rdfs:label $presentationTitle} 		
	 		optional {$presentation vivo:description $description} 					  
	 		optional {$presentation vivo:eventWithin $meeting . $meeting rdfs:label $meetingName}  	 		
	 		optional {$presentation vivo:eventWithin $meeting . $meeting vivo:hasGeographicLocation $geographicLocation . 
	 				  $geographicLocation rdfs:label $meetingLocation}
	 		
	 		optional {{$presentation vivo:dateTimeValue $dateTimeValue . 
	 				  $dateTimeValue hr:dateTime $startDate . $dateTimeValue hr:dateTimePrecision $type}
	 				  union
	 				  {$presentation vivo:relatedRole $rRole .
			 		  $rRole vivo:dateTimeInterval $dateTimeInterval . $dateTimeInterval vivo:start $start . 
			 		  $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $type}}		 	   		 				 		
	 		}	 
	 order by $startDate
	 return	
 		<personsPresentations xsi:type="{if($description = 'Poster') then $description else ()}"> 
	    	<presentationTitle>{$presentationTitle}</presentationTitle>	
	    	<meetingLocation>{$meetingLocation}</meetingLocation>
	    	<meetingName>{$meetingName}</meetingName>
			
			<invited>
			{for * from $graph
			 where {$presentation a vivo:InvitedTalk}
			 return {$true}			
			}
			</invited>	
			
			<meetingDates>
				{local:returnDate($type,$startDate,'startDate')}
			</meetingDates>  		
	     
	        {for * from $graph
	         where {$presentation vivo:relatedRole $relatedRole .
	         		$relatedRole vivo:presenterRoleOf $presenter .
	         		{{$presenter foaf:lastName $contributorFamilyName ; foaf:firstName $contributorGivenName} union {$relatedRole ai:authorNameAsListed $contributorDisplayName}}
	         		optional {$presenter vivo:middleName $contributorMiddleName} 
	         		optional {$relatedRole vivo:authorRank $contributorRank}       		
	         		}
	         return
	         	<authors>
	         		<displayName>{$contributorDisplayName}</displayName>
	         		<positionInSequence>{$contributorRank}</positionInSequence>         			
           			<familyName>{$contributorFamilyName}</familyName>
           			<givenName>{$contributorGivenName}</givenName>
           			<middleNameOrInitial>{substring($contributorMiddleName, 1, 1)}</middleNameOrInitial>           			              	           					
      			</authors>
	         }
	         	                	    			
		</personsPresentations> 		    			
	  }	
   
   
		{for * from $graph
         where {$person vivo:authorInAuthorship $authorship . 
        		$authorship vivo:linkedInformationResource $publication . 
         		$publication rdf:type bibo:Article .         		
         		$publication rdfs:label $publicationTitle .
         		optional {$publication vivo:hasPublicationVenue $journal . $journal rdfs:label $journalTitle}
         		optional {$publication bibo:pmid $pmid}
         		optional {$publication bibo:volume $volume}
         		optional {$publication bibo:issue $issue}         		
         		optional {$publication bibo:status $peerReviewed}
         		optional {$publication vivo:dateTimeValue $dateTimeValue . 
         				  $dateTimeValue vivo:dateTime $publicationDate . $dateTimeValue vivo:dateTimePrecision $type}
         		optional {$publication bibo:status $status . $status rdfs:label $publicationStatus}
         		}
         order by $publicationDate   
         return
            <personsPublications xsi:type="Article">
				<title> {$publicationTitle} </title>
				<journalTitle>{$journalTitle}</journalTitle>
				<pubMedID>{$pmid}</pubMedID>
				<issue>{$issue}</issue>
				<volume>{$volume}</volume>
				
				{for * from $graph
				 where {$publication bibo:pageStart $pageStart ; bibo:pageEnd $pageEnd}
				 return
				 	<pages>{concat($pageStart, "-", $pageEnd)}</pages>
				}
				
				<peerReviewed>
				{if(contains($peerReviewed, 'peerReviewed'))then $true
				 else $false}
				</peerReviewed>
				
				<publicationStatus>{$publicationStatus}</publicationStatus>
           		{local:returnDate($type, $publicationDate, 'publicationDate')}
		        
		        {for * from $graph
                 where  {$publication vivo:informationResourceInAuthorship $contribAuthorship .
                         $contribAuthorship vivo:linkedAuthor $author } 
                 return
                     {for * from $graph
                        where {{{$author foaf:lastName $authorLN ; foaf:firstName $authorFN} union {$author rdfs:label $authorDN}}
                                optional {$contribAuthorship vivo:authorRank $authorRank} 
                                optional {$author vivo:middleName $authorMN}
                               }limit 1
                        order by $authorRank
                        return
                           <contributors>                           	  
                              <givenName>{$authorFN}</givenName>
                              <familyName>{$authorLN}</familyName>
                              <displayName>{$authorDN}</displayName>
                              <middleNameOrInitial>{substring($authorMN, 1, 1)}</middleNameOrInitial>
                              <positionInSequence>{$authorRank}</positionInSequence>
                           </contributors>
                      }
                   }
                   
			</personsPublications>           
    	  }
    	  
    	{for * from $graph
         where {$person vivo:authorInAuthorship $authorship . 
        		$authorship vivo:linkedInformationResource $publication . 
         		$publication rdf:type vivo:ConferencePaper .
         		$publication rdfs:label $title .
         		optional {$publication vivo:dateTimeValue $dateTimeValue . 
         				  $dateTimeValue vivo:dateTime $publicationDate . $dateTimeValue vivo:dateTimePrecision $type}
         		optional {$publication bibo:reproducedIn $proceedings . $proceedings rdfs:label $proceedingsBookTitle . 
         				  $proceedings vivo:proceedingsOf $conference . $conference rdfs:label $conferenceTitle}
         		optional {$publication bibo:presentedAt $conference . $conference rdfs:label $conferenceTitle}
         		optional {$conference vivo:hasGeographicLocation $hasGeographicLocation . $hasGeographicLocation rdfs:label $conferenceLocation}	  
         		optional {$publication bibo:status $status . $status rdfs:label $publicationStatus}
         		optional {$publication bibo:status $peerReviewed}
         		}
         order by $publicationDate
         return
            <personsPublications xsi:type="ConferencePaper">
				<title>{$title}</title>
				<proceedingsBookTitle>{$proceedingsBookTitle}</proceedingsBookTitle>
				<conferenceTitle>{$conferenceTitle}</conferenceTitle>
				<conferenceLocation>{$conferenceLocation}</conferenceLocation>
				<publicationStatus>{$publicationStatus}</publicationStatus>
				
				{for * from $graph
				 where {$publication bibo:pageStart $pageStart ; bibo:pageEnd $pageEnd}
				 return
				 	<pages>{concat($pageStart, "-", $pageEnd)}</pages>
				}
				
				<peerReviewed>
				{if(contains($peerReviewed, 'peerReviewed'))then $true
				 else $false}
				</peerReviewed>	
						
		        {local:returnDate($type, $publicationDate, 'publicationDate')}
		        
		        {for $author $contribAuthorship from $graph
                 where  {$publication vivo:informationResourceInAuthorship $contribAuthorship .
                         $contribAuthorship vivo:linkedAuthor $author } 
                 return
                     {for * from $graph
                        where {{{$author foaf:lastName $authorLN ; foaf:firstName $authorFN} union {$author rdfs:label $authorDN}}
                               optional {$contribAuthorship vivo:authorRank $authorRank} 
                               optional {$author vivo:middleName $authorMN}
                              }limit 1
                        order by $authorRank
                        return
                           <contributors>                           	  
                              <givenName>{$authorFN}</givenName>
                              <familyName>{$authorLN}</familyName>
                              <displayName>{$authorDN}</displayName>
                              <middleNameOrInitial>{substring($authorMN, 1, 1)}</middleNameOrInitial>
                              <positionInSequence>{$authorRank}</positionInSequence>
                           </contributors>
                      }
                   }
		        		       	        		       		              
			</personsPublications>           
    	}  
 
    	  
    	{for * from $graph
         where {$person vivo:authorInAuthorship $authorship . 
        		$authorship vivo:linkedInformationResource $publication . 
         		$publication rdf:type bibo:Book .
         		$publication rdfs:label $bookTitle .
         		optional {$publication vivo:dateTimeValue $dateTimeValue . 
         		          $dateTimeValue vivo:dateTime $publicationDate  . $dateTimeValue vivo:dateTimePrecision $type}
         		optional {$publication vivo:placeOfPublication $publicationLocation}
         		optional {$publication vivo:publisher $hasPublisher . $hasPublisher rdfs:label $publisher}
         		optional {$publication bibo:edition $edition}
         		optional {$publication bibo:status $status . $status rdfs:label $publicationStatus}
         		} 
         return
            <personsPublications xsi:type="Book">
				<title>{$bookTitle}</title>
				<publisher>{$publisher}</publisher>				
				<publicationLocation>{$publicationLocation}</publicationLocation>
				<edition>{$edition}</edition>
				<publicationStatus>{$publicationStatus}</publicationStatus>
			    {local:returnDate($type, $publicationDate, 'publicationDate')}
		         	        
		        {for * from $graph
                 where  {$publication vivo:informationResourceInAuthorship $contribAuthorship .
                         $contribAuthorship vivo:linkedAuthor $author } 
                 return
                     {for * from $graph
                      where {{{$author foaf:lastName $authorLN ; foaf:firstName $authorFN} union {$author rdfs:label $authorDN}}
                             optional {$contribAuthorship vivo:authorRank $authorRank} 
                             optional {$author vivo:middleName $authorMN}
                            }limit 1
                      order by $authorRank
                      return
                         <contributors>                           	  
                            <givenName>{$authorFN}</givenName>
                            <familyName>{$authorLN}</familyName>
                            <displayName>{$authorDN}</displayName>
                            <middleNameOrInitial>{substring($authorMN, 1, 1)}</middleNameOrInitial>
                            <positionInSequence>{$authorRank}</positionInSequence>
                         </contributors>
                     }
                  }		        		       		              
			</personsPublications>           
    	  }    
    	  
    	{for * from $graph
         where {$person vivo:authorInAuthorship $authorship . 
        		$authorship vivo:linkedInformationResource $publication . 
         		$publication rdf:type bibo:BookSection .
         		$publication rdfs:label $title .
         		$publication vivo:partOf $book .
         		$book rdfs:label $bookTitle .
         		optional {$book vivo:dateTimeValue $dateTimeValue . 
         				  $dateTimeValue vivo:dateTime $publicationDate . $dateTimeValue vivo:dateTimePrecision $type}
         		optional {$book vivo:placeOfPublication $publicationLocation}
         		optional {$book vivo:publisher $hasPublisher . $hasPublisher rdfs:label $publisher}
         		optional {$book bibo:status $status . $status rdfs:label $publicationStatus}       		
         		}
         order by $publicationDate
         return
            <personsPublications xsi:type="Chapter">
				<title>{$title}</title>
				<bookTitle>{$bookTitle}</bookTitle>
				<publisher>{$publisher}</publisher>
				
				{for * from $graph
		         where {$publication bibo:pageStart $pageStart ; bibo:pageEnd $pageEnd}
		         return 
		         	<pages>{concat($pageStart, "-", $pageEnd)}</pages>
		        }
		        
				<publicationLocation>{$publicationLocation}</publicationLocation>
				<publicationStatus>{$publicationStatus}</publicationStatus>		
				{local:returnDate($type, $publicationDate, 'publicationDate')}
		        
		        {for * from $graph
		         where {$book bibo:editor $editors . $editors rdfs:label $editorsDisplayName}
		         return
		        	<editors>
            			<displayName>{$editorsDisplayName}</displayName>
        			</editors>
		        }
		        
		        {for $author $contribAuthorship from $graph
                 where  {$publication vivo:informationResourceInAuthorship $contribAuthorship .
                         $contribAuthorship vivo:linkedAuthor $author } 
                 return
                     {for * from $graph
                      where {{{$author foaf:lastName $authorLN ; foaf:firstName $authorFN} union {$author rdfs:label $authorDN}}
                             optional {$contribAuthorship vivo:authorRank $authorRank} 
                             optional {$author vivo:middleName $authorMN}
                            }limit 1
                      order by $authorRank
                      return
                         <contributors>                           	  
                            <givenName>{$authorFN}</givenName>
                            <familyName>{$authorLN}</familyName>
                            <displayName>{$authorDN}</displayName>
                            <middleNameOrInitial>{substring($authorMN, 1, 1)}</middleNameOrInitial>
                            <positionInSequence>{$authorRank}</positionInSequence>
                         </contributors>
                     }
                  }		        		       		              
			</personsPublications>           
    	  }
		
	{for * from $graph
	 where {$person vivo:hasTeacherRole $teacherRole . 
	 		$teacherRole vivo:roleIn $class . 
	 		$class rdfs:label $classTitle
	 		optional {$class ns:classYearTerm $classYearTerm}		
	 		}	 
	 return
	 	<personsActivities xsi:type="vivoTeaching">
	 		<courseTitle>{$classTitle}</courseTitle>
	 		<role>Teacher</role>
        	<schoolOrInstitution></schoolOrInstitution>	 		
 		
	 		{for * from $graph
	 		 where {$teacherRole vivo:dateTimeInterval $dateTimeInterval .
	 		        optional{$dateTimeInterval vivo:start $start . $start vivo:dateTime $startDate . $start vivo:dateTimePrecision $startType}
	 		 		optional{$dateTimeInterval vivo:end $end . $end vivo:dateTime $endDate . $end vivo:dateTimePrecision $endType}
	 		 		}
	 		 order by $startDate		
	 		 return
	 		 <orderedTeachingDates>
	 		 	{local:returnDate($startType, $startDate, 'startDate')}{local:returnDate($endType, $endDate, 'endDate')}
	 		 </orderedTeachingDates>	 		 
	 		}
		 	
	 	</personsActivities>	
	}
			 		  		 
  </DocumentIntermediateFormat>

  else ()
 }
} 
