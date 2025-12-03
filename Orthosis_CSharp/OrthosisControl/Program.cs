using System;
using System.Threading;

namespace OrthosisControl
{
    class OrthosisSystem
    {
        public bool IMU, Accel, FSR, EMG, Flex, PPG;
        public bool Servo, Vib, Pump, LED, Heat, EMS;
        public string State;

        public void ProcessLogic()
        {
            Servo = Vib = Pump = LED = Heat = EMS = false;
            int sensorCount = (IMU?1:0)+(Accel?1:0)+(FSR?1:0)+(EMG?1:0)+(Flex?1:0);

            if (!IMU && !Accel && !FSR && !EMG && !Flex && !PPG)
                State = "IDLE";
            else if (PPG)
                State = "SAFETY";
            else if (sensorCount >= 3)
                State = "ACTIVE_CORRECTION";
            else
                State = "ALERT";

            if (IMU || Accel || FSR || EMG || Flex || PPG) { Vib = true; LED = true; }
            if (PPG) { Servo = Pump = EMS = false; Heat = true; }
            else
            {
                if (IMU || Flex) Servo = true;
                if (FSR) Pump = true;
                if (EMG) Heat = true;
                if (sensorCount >= 3) EMS = true;
            }
        }

        public void Display()
        {
            Console.WriteLine($"State: {State,-20} | IMU:{B(IMU)} Accel:{B(Accel)} FSR:{B(FSR)} EMG:{B(EMG)} Flex:{B(Flex)} PPG:{B(PPG)}");
            Console.WriteLine($"{"",24} | Servo:{B(Servo)} Vib:{B(Vib)} Pump:{B(Pump)} LED:{B(LED)} Heat:{B(Heat)} EMS:{B(EMS)}");
            Console.WriteLine("".PadRight(80,'-'));
        }

        int B(bool b) => b?1:0;
    }
    class Program
    {
        static void Main()
        {
            OrthosisSystem sys = new OrthosisSystem();

            // CASE 1: Semua normal
            sys.IMU = sys.Accel = sys.FSR = sys.EMG = sys.Flex = sys.PPG = false;
            sys.ProcessLogic(); sys.Display();

            // CASE 2: Skenario kamu (IMU, Accel, FSR = 1)
            sys.IMU = true; sys.Accel = true; sys.FSR = true;
            sys.EMG = false; sys.Flex = false; sys.PPG = false;
            sys.ProcessLogic(); sys.Display();

            // CASE 3: Safety (PPG=1)
            sys.IMU = sys.Accel = sys.FSR = sys.EMG = sys.Flex = sys.PPG = true;
            sys.ProcessLogic(); sys.Display();

            // CASE 4: Recovery
            sys.IMU = sys.Accel = sys.FSR = sys.EMG = sys.Flex = sys.PPG = false;
            sys.ProcessLogic(); sys.Display();

            Console.WriteLine("\nSimulation Complete. Press ENTER to exit.");
            Console.ReadLine();
        }
    }
}
