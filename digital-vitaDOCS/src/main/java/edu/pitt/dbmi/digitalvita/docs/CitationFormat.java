/* Copyright 2011 University of Pittsburgh.  All Rights Reserved. */

package edu.pitt.dbmi.digitalvita.docs;

/**
 * Enumerated values to specify a publication citation format. 
 *<br/><br/>
 * Values are VANCOUVER and APA.  These refer to publication citation formats.
 * <br/><br/>
 * Vancouver style is the format most often required for manuscripts submitted to
 * biomedical journals.  The official name of the style, which was developed in 1978
 * by the International Committee of Medical Journal Editors,  is "The Uniform 
 * Requirements for Manuscripts Submitted to Biomedical Journals".  The citation 
 * style specified in the Uniform Requirements is based on the style that was used
 * for approximately 100 years in the Index Medicus, a comprehensive listing of
 * medical publications that was discontinued in 2004, having been replaced by
 * PubMed.  For that reason the style is also sometimes known as "Index Medicus style".
 * The primary reference for the details of the Uniform Requirements is Citing
 * Medicine (1).
 * <br/><br/>
 * APA style was developed in 1929 by a group of psychologists, anthropologists, and
 * business managers convened and sought to establish a simple set of procedures, or
 * style rules, that would codify the many components of scientific writing to increase
 * the ease of reading comprehension.    It is used in many journals in the social and
 * behavioral sciences.   Digital Vita includes an option to create CVs in APA style
 * because that style is used by the University of Pittsburgh's School of Nursing.  The
 * primary reference for APA style is the Publication Manual of the American
 * Psychological Association (2).
 * <br/><br/>
 * <ol>
 * 	<li>
 *    Patrias K. Citing medicine: the NLM style guide for authors, editors, and
 *    publishers [Internet]. 2nd ed. Wendling DL, technical editor. Bethesda (MD): 
 *    National Library of Medicine (US); 2007  [updated 2009 Oct 21].<br/>
 *    Available from: <a href="http://www.nlm.nih.gov/citingmedicine">Citing Medicine</a>.
 *  </li>
 *  <li>
 *    American Psychological Society. (Jul 2009). Publication Manual of the American 
 *    Psychological Association, Sixth Edition.
 *  </li>
 * </ol> 
 *      
 */
public enum CitationFormat
{
	/**
	 * Vancouver format publication citation.  See above for a description.
	 */
	VANCOUVER(1, "vancouver"),
	/**
	 * APA format publication citation.  See above for a description.
	 */
	APA(2, "apa");
	
	private final int value;
	private final String name;
	
	private CitationFormat(int val, String name)
	{
		value = val;
		this.name = name;
	}
	
	/**
	 * Get the numeric value of this enum.
	 * 
	 * @return The integer value of the enumeration.
	 */
	public int getValue()
	{
		return(value);
	}
	
	/**
	 * Get the name of the enumeration.
	 * 
	 * @return A String representation of the enumeration.
	 */
	public String getName()
	{
		return(name);
	}
	
	/**
	 * Given an integer value return the corresponding enumeration.
	 * 
	 * @param val An integer value
	 * 
	 * @return The corresponding enumeration or null if none is found.
	 */
	public static CitationFormat getEnum(int val)
	{
		for(CitationFormat en : values())
		{
			if(val == en.getValue())
				return(en);
		}
		return(null);
	}	
}
