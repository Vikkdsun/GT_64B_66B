`timescale 1ns/1ps

module gt_module(
    input                       i_sys_clk           ,
    input                       i_gt_refclk_p       ,
    input                       i_gt_refclk_n       ,

    /*-------- C1 --------*/
    output                      o_tx0_usrclk        ,
    output                      o_rx0_usrclk        ,

    input                       i_tx0_reset         ,
    input                       i_rx0_reset         ,
    output                      o_tx0_done          ,
    output                      o_rx0_done          ,
    input                       i_data0_valid       ,
    input [8:0]                 i_gt0_drpaddr       ,
    input                       i_gt0_drpclk        ,
    input [15:0]                i_gt0_drpdi         ,
    output [15:0]               o_gt0_drpdo         ,
    input                       i_gt0_drpen         ,
    output                      o_gt0_drprdy        ,
    input                       i_gt0_drpwe         ,
    input                       i_gt0_loopback      ,
    output [63:0]               o_gt0_rxdata        ,
    output                      o_gt0_rxdatavalid   ,
    output [1:0]                o_gt0_rxheader      ,
    output                      o_gt0_rxheadervalid ,
    input                       i_gt0_gtxrxp        ,
    input                       i_gt0_gtxrxn        ,
    input                       i_gt0_rxgearboxslip ,
    input                       i_gt0_rxpolarity    ,
    input                       i_gt0_txpolarity    ,
    input [4:0]                 i_gt0_txpostcursor  ,
    input [4:0]                 i_gt0_txprecursor   ,
    input [3:0]                 i_gt0_txdiffctrl    ,
    input [63:0]                i_gt0_txdata        ,
    output                      o_gt0_gtxtxn        ,
    output                      o_gt0_gtxtxp        ,
    input [1:0]                 i_gt0_txheader      ,
    input [6:0]                 i_gt0_txsequence    ,

    /*-------- C2 --------*/
    output                      o_tx1_usrclk        ,
    output                      o_rx1_usrclk        ,

    input                       i_tx1_reset         ,
    input                       i_rx1_reset         ,
    output                      o_tx1_done          ,
    output                      o_rx1_done          ,
    input                       i_data1_valid       ,
    input [8:0]                 i_gt1_drpaddr       ,
    input                       i_gt1_drpclk        ,
    input [15:0]                i_gt1_drpdi         ,
    output [15:0]               o_gt1_drpdo         ,
    input                       i_gt1_drpen         ,
    output                      o_gt1_drprdy        ,
    input                       i_gt1_drpwe         ,
    input                       i_gt1_loopback      ,
    output [63:0]               o_gt1_rxdata        ,
    output                      o_gt1_rxdatavalid   ,
    output [1:0]                o_gt1_rxheader      ,
    output                      o_gt1_rxheadervalid ,
    input                       i_gt1_gtxrxp        ,
    input                       i_gt1_gtxrxn        ,
    input                       i_gt1_rxgearboxslip ,
    input                       i_gt1_rxpolarity    ,
    input                       i_gt1_txpolarity    ,
    input [4:0]                 i_gt1_txpostcursor  ,
    input [4:0]                 i_gt1_txprecursor   ,
    input [3:0]                 i_gt1_txdiffctrl    ,
    input [63:0]                i_gt1_txdata        ,
    output                      o_gt1_gtxtxn        ,
    output                      o_gt1_gtxtxp        ,
    input [1:0]                 i_gt1_txheader      ,
    input [6:0]                 i_gt1_txsequence    
);

wire                            w_gt_refclk         ;
wire                            w_gt0_qplllock      ;  
wire                            w_gt0_qpllrefclklost;
wire                            w_gt0_qpllreset     ;  
wire                            w_gt0_qplloutclk    ;
wire                            w_gt0_qplloutrefclk ;
wire                            w_tx0_clk           ;
wire                            w_rx0_clk           ;
wire                            w_tx1_clk           ;
wire                            w_rx1_clk           ;
assign                          o_tx0_usrclk = w_tx0_clk;
assign                          o_rx0_usrclk = w_rx0_clk;
assign                          o_tx1_usrclk = w_tx1_clk;
assign                          o_rx1_usrclk = w_rx1_clk;

IBUFDS_GTE2 #(
    .CLKCM_CFG                  ("TRUE"                 ),   // Refer to Transceiver User Guide
    .CLKRCV_TRST                ("TRUE"                 ), // Refer to Transceiver User Guide
    .CLKSWING_CFG               (2'b11                  )  // Refer to Transceiver User Guide
)       
IBUFDS_GTE2_inst (      
   .O                           (w_gt_refclk            ),         // 1-bit output: Refer to Transceiver User Guide
   .ODIV2                       (                       ), // 1-bit output: Refer to Transceiver User Guide
   .CEB                         (0                      ),     // 1-bit input: Refer to Transceiver User Guide
   .I                           (i_gt_refclk_p          ),         // 1-bit input: Refer to Transceiver User Guide
   .IB                          (i_gt_refclk_n          )        // 1-bit input: Refer to Transceiver User Guide
);

GT_64B66B_common #(
    // Simulation attributes
    .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE"                 ),     // Set to "true" to speed up sim reset
    .SIM_QPLLREFCLK_SEL         (3'b001                 )     
)       
GT_64B66B_common_u      
(       
    .QPLLREFCLKSEL_IN           (3'b001                 ),
    .GTREFCLK0_IN               (w_gt_refclk            ),
    .GTREFCLK1_IN               (0                      ),
    .QPLLLOCK_OUT               (w_gt0_qplllock         ),
    .QPLLLOCKDETCLK_IN          (i_sys_clk              ),
    .QPLLOUTCLK_OUT             (w_gt0_qplloutclk       ),
    .QPLLOUTREFCLK_OUT          (w_gt0_qplloutrefclk    ),
    .QPLLREFCLKLOST_OUT         (w_gt0_qpllrefclklost   ),   
    .QPLLRESET_IN               (w_gt0_qpllreset        )
);



gt_channel gt_channel_u0(
    .i_sysclk                   (i_sys_clk              ),
    .i_tx_reset                 (i_tx0_reset            ),
    .i_rx_reset                 (i_rx0_reset            ),
    .o_tx_clk                   (w_tx0_clk              ),
    .o_rx_clk                   (w_rx0_clk              ),
    .o_tx_done                  (o_tx0_done             ),
    .o_rx_done                  (o_rx0_done             ),
    .i_data_valid               (i_data0_valid          ),
    .i_gt0_drpaddr              (i_gt0_drpaddr          ),
    .i_gt0_drpclk               (i_gt0_drpclk           ),
    .i_gt0_drpdi                (i_gt0_drpdi            ),
    .o_gt0_drpdo                (o_gt0_drpdo            ),
    .i_gt0_drpen                (i_gt0_drpen            ),
    .o_gt0_drprdy               (o_gt0_drprdy           ),
    .i_gt0_drpwe                (i_gt0_drpwe            ),
    .i_gt0_loopback             (i_gt0_loopback         ),
    .o_gt0_rxdata               (o_gt0_rxdata           ),
    .o_gt0_rxdatavalid          (o_gt0_rxdatavalid      ),
    .o_gt0_rxheader             (o_gt0_rxheader         ),
    .o_gt0_rxheadervalid        (o_gt0_rxheadervalid    ),
    .i_gt0_gtxrxp               (i_gt0_gtxrxp           ),
    .i_gt0_gtxrxn               (i_gt0_gtxrxn           ),
    .i_gt0_rxgearboxslip        (i_gt0_rxgearboxslip    ),
    .i_gt0_rxpolarity           (i_gt0_rxpolarity       ),
    .i_gt0_txpolarity           (i_gt0_txpolarity       ),
    .i_gt0_txpostcursor         (i_gt0_txpostcursor     ),
    .i_gt0_txprecursor          (i_gt0_txprecursor      ),
    .i_gt0_txdiffctrl           (i_gt0_txdiffctrl       ),
    .i_gt0_txdata               (i_gt0_txdata           ),
    .o_gt0_gtxtxn               (o_gt0_gtxtxn           ),
    .o_gt0_gtxtxp               (o_gt0_gtxtxp           ),
    .i_gt0_txheader             (i_gt0_txheader         ),
    .i_gt0_txsequence           (i_gt0_txsequence       ),
    .i_gt0_qplllock             (w_gt0_qplllock         ),
    .i_gt0_qpllrefclklost       (w_gt0_qpllrefclklost   ),
    .o_gt0_qpllreset            (w_gt0_qpllreset        ),
    .i_gt0_qplloutclk           (w_gt0_qplloutclk       ),
    .i_gt0_qplloutrefclk        (w_gt0_qplloutrefclk    )
);

gt_channel gt_channel_u1(
    .i_sysclk                   (i_sys_clk              ),
    .i_tx_reset                 (i_tx1_reset            ),
    .i_rx_reset                 (i_rx1_reset            ),
    .o_tx_clk                   (w_tx1_clk              ),
    .o_rx_clk                   (w_rx1_clk              ),
    .o_tx_done                  (o_tx1_done             ),
    .o_rx_done                  (o_rx1_done             ),
    .i_data_valid               (i_data1_valid          ),
    .i_gt0_drpaddr              (i_gt1_drpaddr          ),
    .i_gt0_drpclk               (i_gt1_drpclk           ),
    .i_gt0_drpdi                (i_gt1_drpdi            ),
    .o_gt0_drpdo                (o_gt1_drpdo            ),
    .i_gt0_drpen                (i_gt1_drpen            ),
    .o_gt0_drprdy               (o_gt1_drprdy           ),
    .i_gt0_drpwe                (i_gt1_drpwe            ),
    .i_gt0_loopback             (i_gt1_loopback         ),
    .o_gt0_rxdata               (o_gt1_rxdata           ),
    .o_gt0_rxdatavalid          (o_gt1_rxdatavalid      ),
    .o_gt0_rxheader             (o_gt1_rxheader         ),
    .o_gt0_rxheadervalid        (o_gt1_rxheadervalid    ),
    .i_gt0_gtxrxp               (i_gt1_gtxrxp           ),
    .i_gt0_gtxrxn               (i_gt1_gtxrxn           ),
    .i_gt0_rxgearboxslip        (i_gt1_rxgearboxslip    ),
    .i_gt0_rxpolarity           (i_gt1_rxpolarity       ),
    .i_gt0_txpolarity           (i_gt1_txpolarity       ),
    .i_gt0_txpostcursor         (i_gt1_txpostcursor     ),
    .i_gt0_txprecursor          (i_gt1_txprecursor      ),
    .i_gt0_txdiffctrl           (i_gt1_txdiffctrl       ),
    .i_gt0_txdata               (i_gt1_txdata           ),
    .o_gt0_gtxtxn               (o_gt1_gtxtxn           ),
    .o_gt0_gtxtxp               (o_gt1_gtxtxp           ),
    .i_gt0_txheader             (i_gt1_txheader         ),
    .i_gt0_txsequence           (i_gt1_txsequence       ),
    .i_gt0_qplllock             (w_gt1_qplllock         ),
    .i_gt0_qpllrefclklost       (w_gt1_qpllrefclklost   ),
    .o_gt0_qpllreset            (w_gt1_qpllreset        ),
    .i_gt0_qplloutclk           (w_gt1_qplloutclk       ),
    .i_gt0_qplloutrefclk        (w_gt1_qplloutrefclk    )
);


endmodule
