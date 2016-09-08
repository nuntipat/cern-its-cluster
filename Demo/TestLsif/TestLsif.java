
import ch.ntb.usb.*;
import ztex.*;

/**
 * TestLsif - This example demonstrates the usage of the low speed interface of
 * default firmware (i.e. it runs with default firmware).
 *
 * The host software writes 2 numbers to address 0 and 1, the FPGA sum these
 * numbers. The result can be read back from the host through address 2 of the
 * low speed interface.
 */
public class TestLsif extends Ztex1v1
{
    private static final int ADDR_NUM_1 = 0;
    private static final int ADDR_NUM_2 = 1;
    private static final int ADDR_RESULT = 2;

    private static final int NUMBER_1 = 1000;
    private static final int NUMBER_2 = 2500;

    public TestLsif(ZtexDevice1 pDev) throws UsbException
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

        TestLsif ztex = new TestLsif(bus.device(devNum));

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
        String bitStreamPath =  ztex.config.defaultBitstreamPath("testlsif");
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

        // Write two numbers to the FPGA and get result
        try
        {
            ztex.defaultLsiSet(ADDR_NUM_1, NUMBER_1);
            ztex.defaultLsiSet(ADDR_NUM_2, NUMBER_2);
            System.out.println("Writing " + NUMBER_1 + " to addr " + ADDR_NUM_1 + " and " + NUMBER_2 + " to addr " + ADDR_NUM_2 + " of ZTEX SDK low speed interface");
            try
            {
                Thread.sleep(10);
            }
            catch (InterruptedException ex)
            {
            }
            int result = ztex.defaultLsiGet(ADDR_RESULT);
            System.out.println("Result = " + result);
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
