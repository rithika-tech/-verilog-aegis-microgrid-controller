`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2026 23:00:05
// Design Name: 
// Module Name: aegis_controller
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
// AEGIS GRID CONTROLLER
// Deterministic Virtual PLC for Microgrid Stability
// ======================================================
`timescale 1ns/1ps

module aegis_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] freq_raw,      // Frequency ×100 (50.00 Hz = 5000)
    input  wire [7:0]  battery_soc,    // %
    output reg         ess_enable,
    output reg  [2:0]  shed_level,
    output reg         blackout
);

    // Frequency thresholds (×100)
    localparam SAFE_LOW      = 16'd4980;
    localparam SAFE_HIGH     = 16'd5020;
    localparam BLACKOUT_LOW  = 16'd4800;
    localparam BLACKOUT_HIGH = 16'd5200;
    localparam ROCOF_LIMIT   = 17'sd50;   // 0.5 Hz/s

    // FSM states
    localparam INIT    = 3'd0,
               SAFE    = 3'd1,
               WARNING = 3'd2,
               ACTION  = 3'd3,
               FAIL    = 3'd4;

    reg [2:0] state, next_state;

    reg [15:0] freq_prev;
    reg signed [16:0] rocof;

    // RoCoF calculation
    always @(posedge clk) begin
        if (rst) begin
            freq_prev <= 16'd5000;
            rocof     <= 17'sd0;
        end else begin
            rocof     <= $signed(freq_raw) - $signed(freq_prev);
            freq_prev <= freq_raw;
        end
    end

    // FSM state register
    always @(posedge clk) begin
        if (rst)
            state <= INIT;
        else
            state <= next_state;
    end

    // FSM logic
    always @(*) begin
        next_state = state;
        ess_enable = 1'b0;
        shed_level = 3'd0;
        blackout   = 1'b0;

        case (state)
            INIT: begin
                next_state = SAFE;
            end
 
            SAFE: begin
                if (freq_raw < SAFE_LOW || freq_raw > SAFE_HIGH ||
                    rocof > ROCOF_LIMIT || rocof < -ROCOF_LIMIT)
                    next_state = WARNING;
            end

            WARNING: begin
                ess_enable = 1'b1;
                if (freq_raw <= BLACKOUT_LOW || freq_raw >= BLACKOUT_HIGH)
                    next_state = FAIL;
                else
                    next_state = ACTION;
            end

            ACTION: begin
                ess_enable = 1'b1;
                if (battery_soc < 8'd20)
                    shed_level = 3'd1; // Residential shed only

                if (freq_raw >= SAFE_LOW && freq_raw <= SAFE_HIGH)
                    next_state = SAFE;
            end

            FAIL: begin
                blackout = 1'b1;
            end
        endcase
    end
endmodule