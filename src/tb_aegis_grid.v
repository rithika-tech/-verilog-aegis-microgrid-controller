`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2026 10:07:00
// Design Name: 
// Module Name: tb_aegis_grid
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
`timescale 1ns/1ps
module tb_aegis_grid;
    reg clk, rst;
    reg admin_resume;
    reg [15:0] freq;
    reg [7:0] soc;
    wire ess;
    wire [2:0] shed;
    wire paused;
    wire [2:0] state;
    // DUT
    aegis_grid_controller dut (
        .clk(clk),
        .rst(rst),
        .freq_in(freq),
        .battery_soc(soc),
        .admin_resume(admin_resume),
        .ess_enable(ess),
        .shed_level(shed),
        .system_paused(paused),
        .state(state)
    );
    // 1Hz clock
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        admin_resume = 0;
        soc = 80;
        #10 rst = 0;
        // ---------------------------------------
        // NORMAL
        // ---------------------------------------
        freq = 5000; #10;
        // ---------------------------------------
        // FIRST INSTABILITY → ESS
        // ---------------------------------------
        freq = 4800; #10;
        freq = 5000; #10;
        // ---------------------------------------
        // WITHIN COOLDOWN → BLOCKED
        // ---------------------------------------
        freq = 4800; #10;
        freq = 5000; #10;
        // Wait 5 seconds
        #50;
        // ---------------------------------------
        // AFTER COOLDOWN → ESS AGAIN
        // ---------------------------------------
        freq = 4800; #10;
        freq = 5000; #10;
        // ---------------------------------------
        // BURST MODE (5 continuous instabilities)
        // ---------------------------------------
        repeat(5) begin
            freq = 4800; #10;
        end
        // Now system must be paused
        #50;
        // ---------------------------------------
        // ADMIN RESUME
        // ---------------------------------------
        admin_resume = 1; #10;
        admin_resume = 0;
        // Verify recovery
        freq = 4800; #10;
        #50;
        $finish;
    end
endmodule