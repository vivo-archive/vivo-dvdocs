/* Copyright 2011 University of Pittsburgh.  All Rights Reserved. */

package edu.pitt.dbmi.digitalvita.docs;


/**
 * A basic Exception for DVDocs.  DocGenFault extends the generic Exception
 * by adding a user freindly message which can be used to display an error
 * message to an end user.  
 */
public class DocGenException extends Exception
{
	private static final long serialVersionUID = 7823724234L;
	
    private String userFreindlyMessage;
    
    /**
     * Construct a DocGenFault.
     * 
     * @param message A message describing the exception which is suitable 
     *                for posting to a log file.
     * @param userFreindlyMessage A message describing the exception which is
     *                            suitable to display to an end user.
     */
    public DocGenException (String message, String userFreindlyMessage) {
        super (message);
        this.userFreindlyMessage = userFreindlyMessage;
    }
    /**
     * Construct a DocGenFault.
     * 
     * @param message A message describing the exception which is suitable 
     *                for posting to a log file.
     * @param userFreindlyMessage A message describing the exception which is
     *                            suitable to display to an end user.
     * @param cause The root cause of this exception.
     */
    public DocGenException (String message, String userFreindlyMessage, Throwable cause) {
    	super(message, cause);
    	this.userFreindlyMessage = userFreindlyMessage;
    }
    
    /**
     * Get a message describing the exception which is suitable to display to an end user.
     */
    public String getUserFreindlyMessage () {
        return userFreindlyMessage;
    }
}