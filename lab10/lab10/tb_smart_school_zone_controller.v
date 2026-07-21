`timescale 1ns / 1ps

module tb_smart_school_zone_controller;
    reg clk;
    reg reset;
    reg school_mode;
    reg flash_mode;
    reg ped_request;

    wire [2:0] main_light;
    wire [2:0] side_light;
    wire walk_light;
    wire [3:0] countdown;

    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;
    localparam OFF    = 3'b000;

    integer errors;
    integer tick_count;

    smart_school_zone_controller uut (
        .clk(clk),
        .reset(reset),
        .school_mode(school_mode),
        .flash_mode(flash_mode),
        .ped_request(ped_request),
        .main_light(main_light),
        .side_light(side_light),
        .walk_light(walk_light),
        .countdown(countdown)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task check;
        input condition;
        input [1023:0] message;
        begin
            if (condition) begin
                $display("PASS: %0s", message);
            end else begin
                $display("FAIL: %0s at time %0t", message, $time);
                errors = errors + 1;
            end
        end
    endtask

    task check_safe;
        begin
            check(!(main_light == GREEN && side_light == GREEN),
                  "main and side roads are never green at the same time");
            check((walk_light == 1'b0) || (main_light == RED && side_light == RED),
                  "walk light is active only when both roads are red");
        end
    endtask

    task wait_tick;
        begin
            @(posedge clk);
            #1;
            check_safe();
        end
    endtask

    task wait_ticks;
        input integer n;
        begin
            for (tick_count = 0; tick_count < n; tick_count = tick_count + 1) begin
                wait_tick();
            end
        end
    endtask

    task wait_for_walk;
        begin
            while (walk_light != 1'b1) begin
                wait_tick();
            end
        end
    endtask

    task expect_lights;
        input [2:0] expected_main;
        input [2:0] expected_side;
        input expected_walk;
        input [3:0] expected_countdown;
        input [1023:0] message;
        begin
            check(main_light == expected_main, {message, " main light"});
            check(side_light == expected_side, {message, " side light"});
            check(walk_light == expected_walk, {message, " walk light"});
            check(countdown == expected_countdown, {message, " countdown"});
        end
    endtask

    initial begin
        $dumpfile("smart_school_zone.vcd");
        $dumpvars(0, tb_smart_school_zone_controller);

        errors = 0;
        reset = 1'b1;
        school_mode = 1'b0;
        flash_mode = 1'b0;
        ped_request = 1'b0;

        $display("=== Scenario 1: Reset operation ===");
        #2;
        expect_lights(GREEN, RED, 1'b0, 4'd0, "reset returns to safe main green state");
        reset = 1'b0;
        wait_tick();

        $display("=== Scenario 2: Normal traffic cycle ===");
        expect_lights(GREEN, RED, 1'b0, 4'd0, "normal mode starts with main green");
        wait_ticks(9);
        expect_lights(YELLOW, RED, 1'b0, 4'd0, "normal mode reaches main yellow after 10 ticks");
        wait_ticks(3);
        expect_lights(RED, GREEN, 1'b0, 4'd0, "normal mode reaches side green after yellow");
        wait_ticks(8);
        expect_lights(RED, YELLOW, 1'b0, 4'd0, "normal mode skips walk without pedestrian request");
        wait_ticks(3);
        expect_lights(GREEN, RED, 1'b0, 4'd0, "normal mode returns to main green");

        $display("=== Scenario 3: School mode timing ===");
        school_mode = 1'b1;
        wait_tick();
        expect_lights(GREEN, RED, 1'b0, 4'd0, "school mode main green is active");
        wait_ticks(7);
        expect_lights(YELLOW, RED, 1'b0, 4'd0, "school mode shortens main green to 8 ticks");
        wait_ticks(3);
        expect_lights(RED, GREEN, 1'b0, 4'd0, "school mode enters side green");
        wait_ticks(10);
        expect_lights(RED, YELLOW, 1'b0, 4'd0, "school mode extends side green to 10 ticks");
        wait_ticks(3);
        expect_lights(GREEN, RED, 1'b0, 4'd0, "school mode cycle returns to main green");

        $display("=== Scenario 4: Flashing yellow mode ===");
        school_mode = 1'b0;
        flash_mode = 1'b1;
        wait_tick();
        check(side_light == RED, "flashing mode keeps side road red");
        check(main_light == YELLOW || main_light == OFF, "flashing mode drives main road yellow/off");
        wait_tick();
        check(side_light == RED, "flashing mode continues to keep side road red");
        check(main_light == YELLOW || main_light == OFF, "flashing mode continues yellow/off flashing");
        flash_mode = 1'b0;
        wait_tick();
        expect_lights(GREEN, RED, 1'b0, 4'd0, "leaving flashing mode returns to safe main green");

        $display("=== Scenario 5: Pedestrian request and walk countdown ===");
        school_mode = 1'b1;
        ped_request = 1'b1;
        wait_tick();
        ped_request = 1'b0;
        wait_ticks(7);
        expect_lights(YELLOW, RED, 1'b0, 4'd0, "pedestrian request waits through main yellow");
        wait_ticks(3);
        expect_lights(RED, GREEN, 1'b0, 4'd0, "pedestrian request waits through side green");
        wait_for_walk();
        expect_lights(RED, RED, 1'b1, 4'd8, "school walk starts with countdown 8");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd7, "school walk countdown 7");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd6, "school walk countdown 6");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd5, "school walk countdown 5");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd4, "school walk countdown 4");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd3, "school walk countdown 3");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd2, "school walk countdown 2");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd1, "school walk countdown 1");
        wait_tick();
        expect_lights(RED, RED, 1'b1, 4'd0, "school walk countdown 0");
        wait_tick();
        expect_lights(RED, YELLOW, 1'b0, 4'd0, "walk state exits to side yellow");

        $display("=== Scenario 6: Reset during Side Green edge case ===");
        wait_ticks(3);
        school_mode = 1'b0;
        wait_ticks(10);
        wait_ticks(3);
        expect_lights(RED, GREEN, 1'b0, 4'd0, "controller is in side green before edge reset");
        reset = 1'b1;
        #2;
        expect_lights(GREEN, RED, 1'b0, 4'd0, "reset during side green immediately returns safe state");
        reset = 1'b0;
        wait_tick();

        $display("=== Scenario 7: Multiple pedestrian requests while served ===");
        school_mode = 1'b1;
        ped_request = 1'b1;
        wait_tick();
        ped_request = 1'b0;
        wait_ticks(7);
        wait_ticks(3);
        wait_for_walk();
        expect_lights(RED, RED, 1'b1, 4'd8, "first request is being served");
        ped_request = 1'b1;
        wait_ticks(2);
        ped_request = 1'b0;
        wait_ticks(7);
        expect_lights(RED, YELLOW, 1'b0, 4'd0, "extra request during walk does not restart walk");
        wait_ticks(3);
        expect_lights(GREEN, RED, 1'b0, 4'd0, "controller returns to normal sequence after served request");

        if (errors == 0) begin
            $display("=== SIMULATION PASSED: all smart school-zone controller checks succeeded ===");
        end else begin
            $display("=== SIMULATION FAILED: %0d check(s) failed ===", errors);
        end

        $finish;
    end
endmodule
