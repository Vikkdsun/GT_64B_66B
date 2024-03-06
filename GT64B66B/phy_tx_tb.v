`timescale 1ns/1ps

module phy_tx_tb();

reg clk, rst;

reg [63:0]                s_axis_data   ;
reg [7:0]                 s_axis_keep   ;
reg                       s_axis_last   ;
reg                       s_axis_valid  ;

initial begin
    rst = 1;
    #1000;
    @(posedge clk);
    rst = 0;
end

always
begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end 

initial
begin
    s_axis_data  <= 'd0;
    s_axis_keep  <= 'd0;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd0;
    wait(!rst);
    repeat(26)@(posedge clk);

    s_axis_data  <= 64'h1111_1111_1111_1111;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h2222_2222_2222_2222;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h3333_3333_3333_3333;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h4444_4444_4444_4444;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h5555_5555_5555_5555;
    s_axis_keep  <= 8'b1100_0000;
    s_axis_last  <= 'd1;
    s_axis_valid <= 'd1;
    @(posedge clk);

    s_axis_data  <= 'd0;
    s_axis_keep  <= 'd0;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd0;
    @(posedge clk);
    repeat(50)@(posedge clk);

    s_axis_data  <= 64'h1111_1111_1111_1111;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h2222_2222_2222_2222;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h3333_3333_3333_3333;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h4444_4444_4444_4444;
    s_axis_keep  <= 8'b1111_1111;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd1;
    @(posedge clk);
    s_axis_data  <= 64'h5555_5555_5555_5555;
    s_axis_keep  <= 8'b1000_0000;
    s_axis_last  <= 'd1;
    s_axis_valid <= 'd1;
    @(posedge clk);

    s_axis_data  <= 'd0;
    s_axis_keep  <= 'd0;
    s_axis_last  <= 'd0;
    s_axis_valid <= 'd0;
    @(posedge clk);
    repeat(50)@(posedge clk);
end

phy_tx phy_tx_u(
    .i_clk                   (clk),
    .i_rst                   (rst),

    /*---- UserPort ----*/  
    .s_axis_data             (s_axis_data ),
    .s_axis_keep             (s_axis_keep ),
    .s_axis_last             (s_axis_last ),
    .s_axis_valid            (s_axis_valid),
    .s_axis_ready            (),
    .o_gt0_txdata            (),
    .o_gt0_txheader          (),
    .o_gt0_txsequence        ()
);


endmodule
