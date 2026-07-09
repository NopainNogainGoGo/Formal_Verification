`timescale 1ns/1ps

module tb_seq_detect_fsm;

    // ============================================================
    // Signal declaration
    // ============================================================
    logic clk;
    logic rst_n;
    logic din;
    logic detect;

    int pass_cnt;
    int fail_cnt;

    logic [3:0] shift_reg;
    logic golden_detect;

    // ============================================================
    // DUT instance
    // ============================================================
    seq_detect_fsm dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .din    (din),
        .detect (detect)
    );

    // ============================================================
    // Clock generator
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;   // 10 ns clock period
    end

    // ============================================================
    // Golden model function
    // ============================================================
    function automatic logic check_1011(input logic [3:0] data);
        if (data == 4'b1011)
            return 1'b1;
        else
            return 1'b0;
    endfunction

    // ============================================================
    // Reset task
    // ============================================================
    task automatic reset_dut();
        rst_n = 1'b0;
        din   = 1'b0;
        shift_reg = 4'b0000;

        repeat (3) @(negedge clk);

        rst_n = 1'b1;

        repeat (1) @(negedge clk);
    endtask

    // ============================================================
    // Send one bit and check result
    // ============================================================
    task automatic send_bit(input logic bit_in);
        begin
            @(negedge clk);
            din = bit_in;

            shift_reg = {shift_reg[2:0], bit_in};
            golden_detect = check_1011(shift_reg);

            @(posedge clk);
            #1;

            if (detect !== golden_detect) begin
                fail_cnt++;

                $display("[FAIL] time=%0t din=%0b shift=%b detect=%0b expected=%0b",
                         $time, din, shift_reg, detect, golden_detect);
            end
            else begin
                pass_cnt++;

                $display("[PASS] time=%0t din=%0b shift=%b detect=%0b",
                         $time, din, shift_reg, detect);
            end
        end
    endtask

    // ============================================================
    // Main test
    // ============================================================
    initial begin
        pass_cnt = 0;
        fail_cnt = 0;

        reset_dut();

        // --------------------------------------------------------
        // Directed pattern test
        // Pattern: 1011 should be detected
        // --------------------------------------------------------
        $display("===== Directed Test =====");

        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);

        // --------------------------------------------------------
        // Overlap test
        // Example: 1011011 contains two 1011 patterns
        // --------------------------------------------------------
        $display("===== Overlap Test =====");

        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);

        // --------------------------------------------------------
        // Random test
        // --------------------------------------------------------
        $display("===== Random Test =====");

        repeat (50) begin
            send_bit($urandom_range(0, 1));
        end

        // --------------------------------------------------------
        // Result
        // --------------------------------------------------------
        $display("====================================");
        $display("Simulation Finished");
        $display("PASS = %0d", pass_cnt);
        $display("FAIL = %0d", fail_cnt);
        $display("====================================");

        if (fail_cnt == 0)
            $display("TEST PASS");
        else
            $display("TEST FAIL");

        $finish;
    end

    // ============================================================
    // Waveform dump
    // ============================================================
    initial begin
        $fsdbDumpfile("seq_detect_fsm.fsdb");
        $fsdbDumpvars(0, tb_seq_detect_fsm);
    end

endmodule