`timescale 1ns/1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    reg wr_clk = 0;
    reg rd_clk = 0;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Write clock: 10ns
    always #5 wr_clk = ~wr_clk;

    // Read clock: 15ns
    always #7.5 rd_clk = ~rd_clk;

    integer i;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_async_fifo);

        $display("Starting simulation...");

        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20;
        rst = 0;

        @(posedge wr_clk);
      for (i = 0; i < DEPTH+4; i = i + 1) begin
            @(posedge wr_clk);
            wr_en = 1;
            din = i;
            $display("[WRITE] Time=%0t, Data=%0d, Full=%b", $time, din, full);
        end
        wr_en = 0;

        // Check full signal
        @(posedge wr_clk);
        $display("[CHECK] FIFO should now be full: full = %b", full);

        @(posedge wr_clk);
        if (full) begin
            wr_en = 1;
            din = 99;
            $display("[TRY WRITE WHEN FULL] Time=%0t, Data=%0d, Full=%b", $time, din, full);
        end
        wr_en = 0;

        @(posedge rd_clk);
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge rd_clk);
            rd_en = 1;
            $display("[READ] Time=%0t, Data=%0d, Empty=%b", $time, dout, empty);
        end
        rd_en = 0;

        #20;
        @(posedge wr_clk);
        wr_en = 1;
        din = 100;
        $display("[WRITE AFTER READ] Time=%0t, Data=%0d, Full=%b", $time, din, full);
        wr_en = 0;

        #100;
        $display("Simulation finished.");
        $finish;
    end

endmodule
