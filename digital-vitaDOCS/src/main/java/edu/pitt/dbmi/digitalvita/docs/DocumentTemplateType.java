/* Copyright 2011 University of Pittsburgh.  All Rights Reserved. */

package edu.pitt.dbmi.digitalvita.docs;

/**
 * Enumerated values used to specify a document type.  Values are CURRICULUM_VITAE and NIH_BIOSKETCH.
 */
public enum DocumentTemplateType
{
	/**
	 * Curriculum Vitae
	 */
	CURRICULUM_VITAE(1, "curriculum-vitae.fo.xsl"),
	/**
	 * NIH Biosketch
	 */
	NIH_BIOSKETCH(2, "nih-biosketch.fo.xsl");
	
	private final int value;
	private final String templateFileName;
	
	private DocumentTemplateType(int val, String templateFileName)
	{
		value = val;
		this.templateFileName = templateFileName;
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
	 * Get the name of the XSL-FO template used to generate the
	 * document specified by this enum.
	 * 
	 * @return A String representation of the enumeration.
	 */	
	public String getTemplateFileName()
	{
		return(templateFileName);
	}
	
	/**
	 * Given an integer value return the corresponding enumeration.
	 * 
	 * @param val An integer value
	 * 
	 * @return The corresponding enumeration or null if none is found.
	 */	
	public static DocumentTemplateType getEnum(int val)
	{
		for(DocumentTemplateType en : values())
		{
			if(val == en.getValue())
				return(en);
		}
		return(null);
	}	
}
