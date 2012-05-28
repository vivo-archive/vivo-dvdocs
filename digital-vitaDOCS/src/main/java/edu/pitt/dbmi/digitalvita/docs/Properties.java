package edu.pitt.dbmi.digitalvita.docs;

import java.util.HashMap;

/**
 *  An implementation of {@link java.util.Map Map} used to pass named String
 *  values to XSLT as parameters.
 */
public class Properties extends HashMap<String, String>
{
	private static final long serialVersionUID = 392093482345L;
	
	/**
	 *  Get the value of a property with a given name.  If the property
	 *  is not found, null is returned.
	 */
	public String getPropertyValue(String propertyName)
	{
		return(getPropertyValue(propertyName, null));
	}

	/**
	 * Get the value of a property with a given name.  If the property
	 * is not found, the default value is returned.
	 */
	public String getPropertyValue(String propertyName, String defaultValue)
	{
		if(! isEmpty(propertyName))
		{
			String key = propertyName.trim().toUpperCase();
			if(containsKey(key))
				return(get(key));
			else
				return(defaultValue);
		}
		else
			return(defaultValue);
	}
	
	/**
	 * Set the value of a property.
	 */
	public void setPropertyValue(String propertyName, String value)
	{
		if(value != null && propertyName != null && !propertyName.trim().equals(""))
		{
			this.put(propertyName.trim().toUpperCase(), value);
		}
	}
	
	private boolean isEmpty(String val)
	{
		return(val == null || !val.trim().equals(""));
	}
}
