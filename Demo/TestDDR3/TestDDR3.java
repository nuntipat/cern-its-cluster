
import ch.ntb.usb.*;
import ztex.*;

/**
 * 
 * @author Nuntipat Narkthong
 */
public class TestDDR3 extends Ztex1v1
{
    private static final int ADDR_NUM_1 = 0;
    private static final int ADDR_NUM_2 = 1;
    private static final int ADDR_RESULT = 2;
    
    private static final int NUMBER_1 = 1000;
    private static final int NUMBER_2 = 2500;
    
    // TODO: remove to use default path
    //private static final String BITSTREAM_PATH = "/home/wordbox/Documents/CERN/Demo/TestDDR3/TestDDR3/TestDDR3.runs/impl_1/TestDDR3.bit";
    
    public TestDDR3(ZtexDevice1 pDev) throws UsbException
    {
        super(pDev);
    }
    
    /**
     * 
     * @param args the command line arguments
     * @throws ztex.UsbException
     */
    public static void main(String[] args) throws UsbException
    {
        // TODO: allow select other device
        int devNum = 0;
        // TODO: allow reset 
        boolean reset = false;
        
        // init USB stuff
        LibusbJava.usb_init();
        
        // Scan the USB bus
        ZtexScanBus1 bus = new ZtexScanBus1(ZtexDevice1.ztexVendorId, ZtexDevice1.ztexProductId, true, false, 1);
        if (bus.numberOfDevices() <= 0)
        {
            System.err.println("No devices found!!!");
            System.exit(0);
        }
        
        TestDDR3 ztex = new TestDDR3(bus.device(devNum));
        
        // Reset EZ-USB is requested to do so
        if (reset)
        {
            System.out.println("Reseting EZ-USB...");
            try
            {
                ztex.resetEzUsb();
            }
            catch (FirmwareUploadException | InvalidFirmwareException | DeviceLostException ex)
            {
                System.err.println("Can't reset EZ-USB!!!");
                System.exit(0);
            }
        }        

        // Check firmware version and configuration data
        try
        {
            ztex.defaultCheckVersion(1);
        }
        catch (InvalidFirmwareException | CapabilityException ex)
        {
            System.err.println("Device contain older or incompatible firmware!!!");
            System.exit(0);
        }
        
        if (ztex.config == null)
        {
            System.err.println("Invalid device configuration data!!!");
        }
        
        // Upload the bitstream to the device
        String bitStreamPath =  ztex.config.defaultBitstreamPath("TestDDR3");
        System.out.println("Found " + ztex.config.getName());
        System.out.println("Uploading " + bitStreamPath);
        try
        {
            System.out.println("Finished in " + ztex.configureFpga(bitStreamPath, true, -1) + " ms");
        }
        catch (BitstreamReadException | BitstreamUploadException | AlreadyConfiguredException | InvalidFirmwareException | CapabilityException ex)
        {
            System.err.println("Can't upload the bitstream!!!");
            System.exit(0);
        }
        
        // Get test result
        try
        {
            Thread.sleep(2000);
        }
        catch (InterruptedException ex)
        {
        }
        
        int[] result = new int[18];
        try
        {
            ztex.defaultLsiGet(0, result, 18);
            if (result[0] == 1)
            {
                if (result[1] == 0)
                    System.out.println("Finish write data to memory and read back...");
                else
                    System.out.println("Finish write data to memory and read back with some errors!!!");
            }            
            else
            {            
                System.out.println("Device's not done yet!!!");
            }

            for (int i: result)
            {
                System.out.println(String.format("0x%08X", i));
            }
        }
        catch (IndexOutOfBoundsException ex)
        {
            System.err.println("Address specified is not exist!!!");
            System.exit(0);
        }
        catch (UsbException | CapabilityException | InvalidFirmwareException ex)
        {
            System.err.println("Can't connect to the device!!!");
            System.exit(0);
        }
    }
}
