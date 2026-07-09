`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2026 10:06:14
// Design Name: 
// Module Name: aegis_grid_controller
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

module aegis_grid_controller(
    input clk,
    input rst,
    input [15:0] freq_in,
    input [7:0] battery_soc,
    input admin_resume,

    output reg ess_enable,
    output reg [2:0] shed_level,
    output reg system_paused,
    output reg [2:0] state
);

    // =====================================================
    // PARAMETERS
    // =====================================================
    parameter FREQ_THRESHOLD = 16'd4900;
    parameter COOLDOWN_TIME  = 5;
    parameter BURST_LIMIT    = 5;
    parameter BURST_WINDOW   = 10;

    // FSM STATES
    parameter NORMAL   = 3'd0;
    parameter CORRECT  = 3'd1;
    parameter COOLDOWN = 3'd2;
    parameter PAUSED   = 3'd3;

    // =====================================================
    // INTERNAL REGISTERS
    // =====================================================
    reg [31:0] global_time;
    reg [31:0] last_action_time;

    reg [3:0] instability_count;
    reg [31:0] first_instability_time;

    wire instability;
    assign instability = (freq_in < FREQ_THRESHOLD);

    // =====================================================
    // GLOBAL TIMER
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            global_time <= 0;
        else
            global_time <= global_time + 1;
    end

    // =====================================================
    // MAIN FSM
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= NORMAL;
            ess_enable <= 0;
            shed_level <= 0;
            system_paused <= 0;
            last_action_time <= 0;
            instability_count <= 0;
            first_instability_time <= 0;
        end
        else begin

            // Default outputs
            ess_enable <= 0;
            shed_level <= 0;

            case (state)

            // ============================================
            // NORMAL STATE
            // ============================================
            NORMAL: begin

                if (instability) begin

                    // Burst tracking
                    if (instability_count == 0) begin
                        first_instability_time <= global_time;
                        instability_count <= 1;
                    end
                    else if ((global_time - first_instability_time) <= BURST_WINDOW)
                        instability_count <= instability_count + 1;
                    else begin
                        first_instability_time <= global_time;
                        instability_count <= 1;
                    end

                    // Burst detection
                    if (instability_count >= BURST_LIMIT - 1 &&
                        (global_time - first_instability_time) <= BURST_WINDOW) begin
                        system_paused <= 1;
                        state <= PAUSED;
                    end
                    else
                        state <= CORRECT;
                end
            end

            // ============================================
            // CORRECT STATE
            // ============================================
            CORRECT: begin

                if ((global_time - last_action_time) < COOLDOWN_TIME) begin
                    state <= COOLDOWN;   // Cooldown active
                end
                else begin
                    if (battery_soc > 20)
                        ess_enable <= 1;
                    else
                        shed_level <= 3'b001;

                    last_action_time <= global_time;
                    state <= COOLDOWN;
                end
            end

            // ============================================
            // COOLDOWN STATE  (FIXED CLEANLY)
            // ============================================
            COOLDOWN: begin

                if ((global_time - last_action_time) >= COOLDOWN_TIME)
                    state <= NORMAL;
            end

            // ============================================
            // PAUSED STATE
            // ============================================
            PAUSED: begin
                system_paused <= 1;

                if (admin_resume) begin
                    system_paused <= 0;
                    instability_count <= 0;
                    state <= NORMAL;
                end
            end

            default: state <= NORMAL;

            endcase
        end
    end

endmodule
