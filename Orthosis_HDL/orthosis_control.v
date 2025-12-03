module orthosis_controller (
    input wire clk,
    input wire reset,
    input wire IMU,
    input wire Accel,
    input wire FSR,
    input wire EMG,
    input wire Flex,
    input wire PPG,
    output reg Servo,
    output reg Vib,
    output reg Pump,
    output reg LED,
    output reg Heat,
    output reg EMS
);
    reg [2:0] sensor_count;
    
    always @(*) begin
        sensor_count = IMU + Accel + FSR + EMG + Flex;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Servo <= 0; Vib <= 0; Pump <= 0;
            LED <= 0; Heat <= 0; EMS <= 0;
        end
        else begin
            Servo <= 0; Vib <= 0; Pump <= 0;
            LED <= 0; Heat <= 0; EMS <= 0;
            
            if (IMU | Accel | FSR | EMG | Flex | PPG) begin
                Vib <= 1;
                LED <= 1;
            end
            
            if (PPG == 1) begin
                Heat <= 1;
            end
            else begin
                if (IMU | Flex) Servo <= 1;
                if (FSR) Pump <= 1;
                if (EMG) Heat <= 1;
                if (sensor_count >= 3) EMS <= 1;
            end
        end
    end
endmodule

module tb_orthosis;
    reg clk, reset;
    reg IMU, Accel, FSR, EMG, Flex, PPG;
    wire Servo, Vib, Pump, LED, Heat, EMS;
    
    orthosis_controller uut (
        .clk(clk), .reset(reset),
        .IMU(IMU), .Accel(Accel), .FSR(FSR),
        .EMG(EMG), .Flex(Flex), .PPG(PPG),
        .Servo(Servo), .Vib(Vib), .Pump(Pump),
        .LED(LED), .Heat(Heat), .EMS(EMS)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("orthosis.vcd");
        $dumpvars(0, tb_orthosis);
    end
    
    initial begin
        clk = 0; reset = 1;
        IMU = 0; Accel = 0; FSR = 0; EMG = 0; Flex = 0; PPG = 0;
        
        $display("WEARABLE SMART ORTHOSIS - SIMULATION");
        $display("Time | IMU Acc FSR EMG Flx PPG | Srv Vib Pmp LED Ht EMS");
        $display("-----|------------------------|-------------------------");
        
        #10 reset = 0;
        
        #10 IMU=0; Accel=0; FSR=0; EMG=0; Flex=0; PPG=0;
        #10 $display("%4d |  %b   %b   %b   %b   %b   %b  |  %b   %b   %b   %b   %b   %b",
                     $time, IMU, Accel, FSR, EMG, Flex, PPG, Servo, Vib, Pump, LED, Heat, EMS);
        
        #10 IMU=1; Accel=1; FSR=1; EMG=0; Flex=0; PPG=0;
        #10 $display("%4d |  %b   %b   %b   %b   %b   %b  |  %b   %b   %b   %b   %b   %b  <- ACTIVE",
                     $time, IMU, Accel, FSR, EMG, Flex, PPG, Servo, Vib, Pump, LED, Heat, EMS);
        
        #10 IMU=1; Accel=1; FSR=1; EMG=1; Flex=1; PPG=1;
        #10 $display("%4d |  %b   %b   %b   %b   %b   %b  |  %b   %b   %b   %b   %b   %b  <- SAFETY",
                     $time, IMU, Accel, FSR, EMG, Flex, PPG, Servo, Vib, Pump, LED, Heat, EMS);
        
        #20 $finish;
    end
endmodule
