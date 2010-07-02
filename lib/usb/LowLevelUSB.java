import java.io.IOException;
import java.util.HashMap;

class LowLevelUSB
{
    private native void initializeUSB (int debug) throws IOException;
    private native byte[] fetchData () throws IOException;
    public native void close ();
    
    public LowLevelUSB (int debug) throws IOException
    {
	try
	    {
		initializeUSB (debug);
	    }
	catch (IOException ex)
	    {
		throw ex;
	    }
    }
    
    public HashMap getInfo () throws IOException
    {
	// format is as follows: <have t.s?> <n. of t.s> <have ac.?> <t values> <h value(s)>
	boolean haveTS = false, haveAC = false;
	int numberOfTS = 0;
	byte b;
	HashMap<Object, Object> result = new HashMap<Object, Object> ();
	byte[] data = new byte[256];

	try
	    {
		data = fetchData ();
	    }
	catch (IOException ex)
	    {
		throw ex;
	    }
	b = data[0];
	if ((b & (~b | 1)) == 1)
	    {
		haveTS = true;
		numberOfTS = b >> 2;
		int TSValues[] = new int[numberOfTS];
		for (int i = 0; i < numberOfTS; i += 2)
		    {
			TSValues[i] = (0xFF & data[i + 1]) | (0xFF & data[i + 2]) << 8;
		    }
		result.put ("TSValues", TSValues);
	    }
	result.put ("haveTS", haveTS);
	result.put ("numberOfTS", numberOfTS);
	// accelerometer-presence bit in second, so this has to equal 2
	if ((b & (~b | 1 << 1)) == 2)
	    {
		haveAC = true;
		int index;
		int nSets = (data.length - 4) / 6;
		int ACValues[][] = new int[nSets][3];
		for (int i = 0; i < nSets; i++)
		    {
			for (int j = 0; j < 3; j++)
			    {
				index = 3 + i*6 + j*2;
				// System.out.println (index + " " + i + " " + j);
				ACValues[i][j] = data[index] | data[index + 1] << 8;
				// System.out.println (ACValues[i][j]);
				// j++;
			    }
		    }	
		result.put ("ACValues", ACValues);		
	    }
	result.put ("haveAC", haveAC);
	int HValues[] = new int[1];
	// System.out.println ("there");
	HValues[0] = data[data.length - 1];
	result.put ("HValues", HValues);
	return result;
    }
    
    static
    {
        System.loadLibrary ("LowLevelUSB");
    }
}