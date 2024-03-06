`timescale 1ns/1ps

module phy_tx(
    input                       i_clk                   ,
    input                       i_rst                   ,

    /*---- UserPort ----*/  
    input [63:0]                s_axis_data             ,
    input [7:0]                 s_axis_keep             ,
    input                       s_axis_last             ,
    input                       s_axis_valid            ,
    output                      s_axis_ready            ,

    /*---- GT_Port ----*/   
    output [63:0]               o_gt0_txdata            ,
    output [1:0]                o_gt0_txheader          ,
    output [6:0]                o_gt0_txsequence        
);

reg [63:0]                      ro_gt0_txdata           ;
reg [1:0]                       ro_gt0_txheader         ;
reg [5:0]                       r_gt0_txsequence        ;
reg                             rs_axis_ready           ;

reg                             rs_axis_last            ;

reg                             rs_axis_valid           ;
// reg                             rs_axis_valid_1d        ;
reg                             r_fifo_rden             ;
reg [15:0]                      r_recv_cnt              ;
reg [15:0]                      r_save_len              ;
reg [7:0]                       r_save_keep             ;
reg                             r_rd_run                ;
reg                             r_rd_run_1d             ;
reg [15:0]                      r_rd_cnt                ;
reg [15:0]                      r_rd_cnt_1d             ;
reg                             r_fifo_empty            ;
reg [63:0]                      r_fifo_dout             ;
reg                             r_rden_end              ;
wire [63:0]                     w_fifo_dout             ;
wire                            w_fifo_full             ;
wire                            w_fifo_empty            ;
wire                            w_rden_begin            ;
wire                            w_rden_end_pre           ;
wire                            w_len_valid             ;


assign                          o_gt0_txsequence = {1'b0, r_gt0_txsequence};
assign                          o_gt0_txdata     = ro_gt0_txdata  ;
assign                          o_gt0_txheader   = ro_gt0_txheader;
assign                          w_rden_begin     = r_fifo_empty & !w_fifo_empty;
assign                          w_len_valid      = ~(s_axis_valid || rs_axis_valid);
assign                          s_axis_ready     = rs_axis_ready;
assign                          w_rden_end_pre    = r_rd_run_1d & !r_rd_run;

FIFO_TX FIFO_TX_u (
    .clk        (i_clk          ),      // input wire clk
    .din        (s_axis_data    ),      // input wire [63 : 0] din
    .wr_en      (s_axis_valid   ),  // input wire wr_en
    .rd_en      (r_fifo_rden    ),  // input wire rd_en
    .dout       (w_fifo_dout    ),    // output wire [63 : 0] dout
    .full       (w_fifo_full    ),    // output wire full
    .empty      (w_fifo_empty   )  // output wire empty
);

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_save_keep <= 'd0;
    else if (s_axis_last)
        r_save_keep <= s_axis_keep;
    else
        r_save_keep <= r_save_keep;
end 

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_fifo_empty <= 'd1;
    else
        r_fifo_empty <= w_fifo_empty;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_fifo_dout <= 'd0;
    else
        r_fifo_dout <= w_fifo_dout;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        rs_axis_valid    <= 'd0;
    end else begin
        rs_axis_valid    <= s_axis_valid;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_recv_cnt <= 'd0;
    else if (s_axis_valid)
        r_recv_cnt <= r_recv_cnt + 1;
    else
        r_recv_cnt <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        rs_axis_last <= 'd0;
    else
        rs_axis_last <= s_axis_last;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_save_len <= 'd0;
    else if (rs_axis_last)
        r_save_len <= r_recv_cnt;
    else
        r_save_len <= r_save_len;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_gt0_txsequence <= 'd0;
    else if (r_gt0_txsequence == 32)
        r_gt0_txsequence <= 'd0;
    else
        r_gt0_txsequence <= r_gt0_txsequence + 1;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rd_run <= 'd0;
    else if (r_rd_cnt == r_save_len && w_len_valid)
        r_rd_run <= 'd0;
    else if (w_rden_begin)
        r_rd_run <= 'd1;
    else
        r_rd_run <= r_rd_run;
end 

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rd_run_1d <= 'd0;
    else
        r_rd_run_1d <= r_rd_run;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_fifo_rden <= 'd0;
    else if ((w_rden_begin || r_rd_run) && r_gt0_txsequence == 'd30 || w_fifo_empty)
        r_fifo_rden <= 'd0;
    else if ((w_rden_begin || r_rd_run) && r_gt0_txsequence != 'd30)
        r_fifo_rden <= 'd1;
    else
        r_fifo_rden <= r_fifo_rden;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rd_cnt <= 'd0;
    else if (r_rd_cnt == r_save_len && w_len_valid)
        r_rd_cnt <= 'd0;
    else if (r_fifo_rden)
        r_rd_cnt <= r_rd_cnt + 1;
    else
        r_rd_cnt <= r_rd_cnt;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rd_cnt_1d <= 'd0;
    else 
        r_rd_cnt_1d <= r_rd_cnt;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_gt0_txdata <= 'd0;
    else if (r_rd_cnt_1d == r_rd_cnt)
        ro_gt0_txdata <= ro_gt0_txdata;
    else if (r_save_keep >= 8'b1111_1110 && r_rd_cnt_1d == r_save_len) begin
        case(r_save_keep)
            8'b1111_1110 : ro_gt0_txdata <= {7'h16,7'h16,7'h16,7'h16,7'h16,7'h16,7'h16,7'h16,8'h8e};
            8'b1111_1111 : ro_gt0_txdata <= {7'h16,7'h16,7'h16,7'h16,7'h16,7'h16,6'd0,r_fifo_dout[7:0],8'h99};
        endcase
    end else if (r_save_keep <= 8'b1111_1100 && r_rd_cnt == r_save_len) begin
        case(r_save_keep)
            8'b1111_1100 : ro_gt0_txdata <= {w_fifo_dout[23:16], w_fifo_dout[31:24], w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56],r_fifo_dout[7:0],8'hFF};
            8'b1111_1000 : ro_gt0_txdata <= {7'h16,1'd0,w_fifo_dout[31:24], w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56],r_fifo_dout[7:0],8'he8};
            8'b1111_0000 : ro_gt0_txdata <= {7'h16,7'h16,2'd0,w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56],r_fifo_dout[7:0],8'hD4};
            8'b1110_0000 : ro_gt0_txdata <= {7'h16,7'h16,7'h16,3'd0,w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56],r_fifo_dout[7:0],8'hc3};
            8'b1100_0000 : ro_gt0_txdata <= {7'h16,7'h16,7'h16,7'h16,4'd0,w_fifo_dout[55:48], w_fifo_dout[63:56],r_fifo_dout[7:0],8'hB2};
            8'b1000_0000 : ro_gt0_txdata <= {7'h16,7'h16,7'h16,7'h16,7'h16,5'd0,w_fifo_dout[63:56],r_fifo_dout[7:0],8'hA5};
        endcase
    end else if (r_rd_cnt == 'd1)
        ro_gt0_txdata <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56], 8'h71};
    else if (r_rd_run)          
        ro_gt0_txdata <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56], r_fifo_dout[7:0]};
    else
        ro_gt0_txdata <= {w_fifo_dout[15:8], w_fifo_dout[23:16], w_fifo_dout[31:24], w_fifo_dout[39:32], w_fifo_dout[47:40], w_fifo_dout[55:48], w_fifo_dout[63:56], r_fifo_dout[7:0]};
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_gt0_txheader <= 'd0;
    else if (r_save_keep >= 8'b1111_1110 && r_rd_cnt_1d == r_save_len)
        ro_gt0_txheader <= 2'b10;
    else if (r_save_keep <= 8'b1111_1100 && r_rd_cnt == r_save_len)
        ro_gt0_txheader <= 2'b10;
    else if (r_rd_cnt == 'd1)
        ro_gt0_txheader <= 2'b10;
    else
        ro_gt0_txheader <= 2'b01;
end 

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_rden_end <= 'd0;
    else
        r_rden_end <= w_rden_end_pre;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        rs_axis_ready <= 'd1;
    else if (s_axis_last)      
        rs_axis_ready <= 'd0;
    else if (r_rden_end)
        rs_axis_ready <= 'd1;
    else    
        rs_axis_ready <= rs_axis_ready;
end


endmodule
