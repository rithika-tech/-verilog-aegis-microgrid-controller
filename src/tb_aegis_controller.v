`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2026 23:01:00
// Design Name: 
// Module Name: tb_aegis_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ======================================================
// TESTBENCH - AEGIS GRID CONTROLLER
// Deterministic Virtual PLC Simulation
// ======================================================
`timescale 1ns/1ps
module tb_aegis_controller;
    reg clk, rst;
    reg [15:0] freq_raw;
    reg [7:0]  battery_soc;
    wire ess_enable;
    wire [2:0] shed_level;
    wire blackout;
    aegis_controller dut (
        .clk(clk),
        .rst(rst),
        .freq_raw(freq_raw),
        .battery_soc(battery_soc),
        .ess_enable(ess_enable),
        .shed_level(shed_level),
        .blackout(blackout)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        // Nominal
        freq_raw    = 16'd5000; // 50.00 Hz
        battery_soc = 8'd50;
        #20 rst = 0;
        // ---- Solar loss (RoCoF event) ----
        #20 freq_raw = 16'd4970; // 49.70
        #20 freq_raw = 16'd4920; // 49.20
        // ---- Industrial spike ----
        #20 battery_soc = 8'd15;
        #20 freq_raw = 16'd4880; // 48.80
        // ---- Recovery ----
        #20 battery_soc = 8'd40;
        #20 freq_raw = 16'd4990;
        #20 freq_raw = 16'd5000;
        #100 $finish;
    end
endmodule