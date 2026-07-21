`timescale 1ns / 1ps

module smart_school_zone_controller(
    input clk,
    input reset,
    input school_mode,
    input flash_mode,
    input ped_request,
    output reg [2:0] main_light,
    output reg [2:0] side_light,
    output reg walk_light,
    output reg [3:0] countdown
);
    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;
    localparam OFF    = 3'b000;

    localparam S0_MAIN_GREEN  = 3'd0;
    localparam S1_MAIN_YELLOW = 3'd1;
    localparam S2_SIDE_GREEN  = 3'd2;
    localparam S3_SIDE_YELLOW = 3'd3;
    localparam S4_WALK        = 3'd4;

    localparam NORMAL_MAIN_GREEN_TICKS = 4'd10;
    localparam SCHOOL_MAIN_GREEN_TICKS = 4'd8;
    localparam NORMAL_SIDE_GREEN_TICKS = 4'd8;
    localparam SCHOOL_SIDE_GREEN_TICKS = 4'd10;
    localparam YELLOW_TICKS            = 4'd3;
    localparam NORMAL_WALK_SECONDS     = 4'd5;
    localparam SCHOOL_WALK_SECONDS     = 4'd8;

    reg [2:0] state;
    reg [3:0] timer;
    reg [3:0] limit;
    reg ped_pending;
    reg flash_toggle;

    wire flash_active = flash_mode && !school_mode;
    wire [3:0] walk_seconds = school_mode ? SCHOOL_WALK_SECONDS : NORMAL_WALK_SECONDS;

    always @(*) begin
        limit = NORMAL_MAIN_GREEN_TICKS;
        countdown = 4'd0;

        if (flash_active) begin
            main_light = flash_toggle ? YELLOW : OFF;
            side_light = RED;
            walk_light = 1'b0;
        end else begin
            case (state)
                S0_MAIN_GREEN: begin
                    main_light = GREEN;
                    side_light = RED;
                    walk_light = 1'b0;
                    limit = school_mode ? SCHOOL_MAIN_GREEN_TICKS : NORMAL_MAIN_GREEN_TICKS;
                end

                S1_MAIN_YELLOW: begin
                    main_light = YELLOW;
                    side_light = RED;
                    walk_light = 1'b0;
                    limit = YELLOW_TICKS;
                end

                S2_SIDE_GREEN: begin
                    main_light = RED;
                    side_light = GREEN;
                    walk_light = 1'b0;
                    limit = school_mode ? SCHOOL_SIDE_GREEN_TICKS : NORMAL_SIDE_GREEN_TICKS;
                end

                S3_SIDE_YELLOW: begin
                    main_light = RED;
                    side_light = YELLOW;
                    walk_light = 1'b0;
                    limit = YELLOW_TICKS;
                end

                S4_WALK: begin
                    main_light = RED;
                    side_light = RED;
                    walk_light = 1'b1;
                    limit = walk_seconds + 4'd1;
                    countdown = (timer <= walk_seconds) ? (walk_seconds - timer) : 4'd0;
                end

                default: begin
                    main_light = GREEN;
                    side_light = RED;
                    walk_light = 1'b0;
                    limit = school_mode ? SCHOOL_MAIN_GREEN_TICKS : NORMAL_MAIN_GREEN_TICKS;
                end
            endcase
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0_MAIN_GREEN;
            timer <= 4'd0;
            ped_pending <= 1'b0;
            flash_toggle <= 1'b1;
        end else if (flash_active) begin
            state <= S0_MAIN_GREEN;
            timer <= 4'd0;
            ped_pending <= 1'b0;
            flash_toggle <= ~flash_toggle;
        end else begin
            flash_toggle <= 1'b1;

            if (ped_request && (state != S4_WALK)) begin
                ped_pending <= 1'b1;
            end

            if (timer >= limit - 4'd1) begin
                timer <= 4'd0;

                case (state)
                    S0_MAIN_GREEN: begin
                        state <= S1_MAIN_YELLOW;
                    end

                    S1_MAIN_YELLOW: begin
                        state <= S2_SIDE_GREEN;
                    end

                    S2_SIDE_GREEN: begin
                        if (ped_pending || ped_request) begin
                            state <= S4_WALK;
                            ped_pending <= 1'b0;
                        end else begin
                            state <= S3_SIDE_YELLOW;
                        end
                    end

                    S4_WALK: begin
                        state <= S3_SIDE_YELLOW;
                    end

                    S3_SIDE_YELLOW: begin
                        state <= S0_MAIN_GREEN;
                    end

                    default: begin
                        state <= S0_MAIN_GREEN;
                    end
                endcase
            end else begin
                timer <= timer + 4'd1;
            end
        end
    end
endmodule
