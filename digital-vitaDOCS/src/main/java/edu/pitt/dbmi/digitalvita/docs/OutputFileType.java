package edu.pitt.dbmi.digitalvita.docs;

/**
 * Enumerated values used to specify a file type.  Values are PDF and RTF.
 */
public enum OutputFileType {

	/**
	 * Rich Text Format (rtf)
	 */
	RTF(1, "rtf", "application/rtf"),
	/**
	 * Portable Document Format (pdf)
	 */
	PDF(2, "pdf", "application/pdf");
	
	private final int value;
	private final String extension;
	private final String mimeType;
	private OutputFileType(int val, String extension, String mimeType)
	{
		value = val;
		this.extension = extension;
		this.mimeType = mimeType;
	}
	
	/**
	 * Returns the file extension for the file type specified by the enum. 
	 */
	public String getExtension()
	{
		return(extension);
	}
	
	/**
	 * Returns the mime type for the file type specified.
	 */
	public String getMimeType()
	{
		return(mimeType);
	}
	/**
	 * Returns the integer value of the enum. 
	 */
	public int getValue()
	{
		return(value);
	}
	
	/**
	 * Given an integer value return the corresponding enumeration.
	 * 
	 * @param val An integer value
	 * 
	 * @return The corresponding enumeration or null if none is found.
	 */		
	public static OutputFileType getEnum(int val)
	{
		for(OutputFileType en : values())
		{
			if(val == en.getValue())
				return(en);
		}
		return(null);
	}		
}
