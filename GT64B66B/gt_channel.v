`timescale 1ns/1ps

module gt_channel(
    input                       i_sysclk            ,
    input                       i_tx_reset          ,
    input                       i_rx_reset          ,
    
    output                      o_tx_clk            ,
    output                      o_rx_clk            ,
    output                      o_tx_done           ,
    output                      o_rx_done           ,

    input                       i_data_valid        ,


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

    input                       i_gt0_qplllock      ,
    input                       i_gt0_qpllrefclklost,
    output                      o_gt0_qpllreset     ,
    input                       i_gt0_qplloutclk    ,
    input                       i_gt0_qplloutrefclk 

);

wire                            w_common_reset                  ;
wire                            w_gt0_qpllreset                 ;
wire                            w_gt0_txoutclk                  ;
wire                            w_gt0_tx_mmcm_lock              ;
wire                            w_gt0_tx_mmcm_reset             ;
wire                            w_gt0_rx_mmcm_lock              ;
wire                            w_gt0_rx_mmcm_reset             ;
wire                            w_tx_userclk                    ;
wire                            w_tx_userclk2                   ;
wire                            w_rx_userclk                    ;
wire                            w_rx_userclk2                   ;

assign                          o_gt0_qpllreset = w_common_reset | w_gt0_qpllreset;
assign                          o_tx_clk = w_tx_userclk2;
assign                          o_rx_clk = w_rx_userclk2;

GT_64B66B_common_reset #(
    .STABLE_CLOCK_PERIOD            (8                      )        // Period of the stable clock driving this state-machine, unit is [ns]
)
GT_64B66B_common_reset_u
(    
    .STABLE_CLOCK                   (i_sysclk               ),             //Stable Clock, either a stable clock from the PCB
    .SOFT_RESET                     (i_tx_reset             ),               //User Reset, can be pulled any time
    .COMMON_RESET                   (w_common_reset         )         //Reset QPLL
);

GT_64B66B_GT_USRCLK_SOURCE GT_64B66B_GT_USRCLK_SOURCE_u
( 
    .GT0_TXUSRCLK_OUT               (w_tx_userclk           ),
    .GT0_TXUSRCLK2_OUT              (w_tx_userclk2          ),
    .GT0_TXOUTCLK_IN                (w_gt0_txoutclk         ),
    .GT0_TXCLK_LOCK_OUT             (w_gt0_tx_mmcm_lock     ),
    .GT0_TX_MMCM_RESET_IN           (w_gt0_tx_mmcm_reset    ),
    .GT0_RXUSRCLK_OUT               (w_rx_userclk           ),
    .GT0_RXUSRCLK2_OUT              (w_rx_userclk2          ),
    .GT0_RXCLK_LOCK_OUT             (w_gt0_rx_mmcm_lock     ),
    .GT0_RX_MMCM_RESET_IN           (w_gt0_rx_mmcm_reset    )
);

GT_64B66B  GT_64B66B_u
(
    .sysclk_in                      (i_sysclk               ), // input wire sysclk_in
    .soft_reset_tx_in               (i_tx_reset             ), // input wire soft_reset_tx_in
    .soft_reset_rx_in               (i_rx_reset             ), // input wire soft_reset_rx_in

    .dont_reset_on_data_error_in    (0                      ), // input wire dont_reset_on_data_error_in

    .gt0_tx_fsm_reset_done_out      (o_tx_done              ), // output wire gt0_tx_fsm_reset_done_out
    .gt0_rx_fsm_reset_done_out      (o_rx_done              ), // output wire gt0_rx_fsm_reset_done_out

    .gt0_data_valid_in              (i_data_valid           ), // input wire gt0_data_valid_in

    .gt0_tx_mmcm_lock_in            (w_gt0_tx_mmcm_lock     ), // input wire gt0_tx_mmcm_lock_in
    .gt0_tx_mmcm_reset_out          (w_gt0_tx_mmcm_reset    ), // output wire gt0_tx_mmcm_reset_out
    .gt0_rx_mmcm_lock_in            (w_gt0_rx_mmcm_lock     ), // input wire gt0_rx_mmcm_lock_in
    .gt0_rx_mmcm_reset_out          (w_gt0_rx_mmcm_reset    ), // output wire gt0_rx_mmcm_reset_out

    .gt0_drpaddr_in                 (i_gt0_drpaddr          ), // input wire [8:0] gt0_drpaddr_in
    .gt0_drpclk_in                  (i_gt0_drpclk           ), // input wire gt0_drpclk_in
    .gt0_drpdi_in                   (i_gt0_drpdi            ), // input wire [15:0] gt0_drpdi_in
    .gt0_drpdo_out                  (o_gt0_drpdo            ), // output wire [15:0] gt0_drpdo_out
    .gt0_drpen_in                   (i_gt0_drpen            ), // input wire gt0_drpen_in
    .gt0_drprdy_out                 (o_gt0_drprdy           ), // output wire gt0_drprdy_out
    .gt0_drpwe_in                   (i_gt0_drpwe            ), // input wire gt0_drpwe_in
    
    .gt0_dmonitorout_out            (                       ), // output wire [7:0] gt0_dmonitorout_out
    .gt0_loopback_in                (i_gt0_loopback         ), // input wire [2:0] gt0_loopback_in
    .gt0_eyescanreset_in            (0                      ), // input wire gt0_eyescanreset_in
    .gt0_rxuserrdy_in               (1                      ), // input wire gt0_rxuserrdy_in
    .gt0_eyescandataerror_out       (                       ), // output wire gt0_eyescandataerror_out
    .gt0_eyescantrigger_in          (0                      ), // input wire gt0_eyescantrigger_in
    .gt0_rxclkcorcnt_out            (                       ), // output wire [1:0] gt0_rxclkcorcnt_out

    .gt0_rxusrclk_in                (w_rx_userclk           ), // input wire gt0_rxusrclk_in
    .gt0_rxusrclk2_in               (w_rx_userclk2          ), // input wire gt0_rxusrclk2_in

    .gt0_rxdata_out                 (o_gt0_rxdata           ), // output wire [63:0] gt0_rxdata_out
    .gt0_rxdatavalid_out            (o_gt0_rxdatavalid      ), // output wire gt0_rxdatavalid_out
    .gt0_rxheader_out               (o_gt0_rxheader         ), // output wire [1:0] gt0_rxheader_out
    .gt0_rxheadervalid_out          (o_gt0_rxheadervalid    ), // output wire gt0_rxheadervalid_out
    
    .gt0_gtxrxp_in                  (i_gt0_gtxrxp           ), // input wire gt0_gtxrxp_in
    .gt0_gtxrxn_in                  (i_gt0_gtxrxn           ), // input wire gt0_gtxrxn_in

    .gt0_rxdfelpmreset_in           (0                      ), // input wire gt0_rxdfelpmreset_in
    .gt0_rxmonitorout_out           (                       ), // output wire [6:0] gt0_rxmonitorout_out
    .gt0_rxmonitorsel_in            (0                      ), // input wire [1:0] gt0_rxmonitorsel_in
    .gt0_rxoutclkfabric_out         (                       ), // output wire gt0_rxoutclkfabric_out
    
    
    .gt0_rxgearboxslip_in           (i_gt0_rxgearboxslip    ), // input wire gt0_rxgearboxslip_in
    .gt0_gtrxreset_in               (i_rx_reset             ), // input wire gt0_gtrxreset_in
    .gt0_rxpmareset_in              (i_rx_reset             ), // input wire gt0_rxpmareset_in
    .gt0_rxpolarity_in              (i_gt0_rxpolarity       ), // input wire gt0_rxpolarity_in

    .gt0_rxresetdone_out            (                       ), // output wire gt0_rxresetdone_out

    .gt0_txpostcursor_in            (i_gt0_txpostcursor     ), // input wire [4:0] gt0_txpostcursor_in
    .gt0_txprecursor_in             (i_gt0_txprecursor      ), // input wire [4:0] gt0_txprecursor_in

    .gt0_gttxreset_in               (i_tx_reset             ), // input wire gt0_gttxreset_in
    .gt0_txuserrdy_in               (1                      ), // input wire gt0_txuserrdy_in
    .gt0_txusrclk_in                (w_tx_userclk           ), // input wire gt0_txusrclk_in
    .gt0_txusrclk2_in               (w_tx_userclk2          ), // input wire gt0_txusrclk2_in
    .gt0_txdiffctrl_in              (i_gt0_txdiffctrl       ), // input wire [3:0] gt0_txdiffctrl_in
    .gt0_txdata_in                  (i_gt0_txdata           ), // input wire [63:0] gt0_txdata_in
    .gt0_gtxtxn_out                 (o_gt0_gtxtxn           ), // output wire gt0_gtxtxn_out
    .gt0_gtxtxp_out                 (o_gt0_gtxtxp           ), // output wire gt0_gtxtxp_out

    .gt0_txoutclk_out               (w_gt0_txoutclk         ), // output wire gt0_txoutclk_out
    .gt0_txoutclkfabric_out         (                       ), // output wire gt0_txoutclkfabric_out
    .gt0_txoutclkpcs_out            (                       ), // output wire gt0_txoutclkpcs_out
    .gt0_txheader_in                (i_gt0_txheader         ), // input wire [1:0] gt0_txheader_in

    .gt0_txsequence_in              (i_gt0_txsequence       ), // input wire [6:0] gt0_txsequence_in

    .gt0_txresetdone_out            (                       ), // output wire gt0_txresetdone_out

    .gt0_txpolarity_in              (i_gt0_txpolarity       ), // input wire gt0_txpolarity_in

    .gt0_qplllock_in                (i_gt0_qplllock         ), // input wire gt0_qplllock_in
    .gt0_qpllrefclklost_in          (i_gt0_qpllrefclklost   ), // input wire gt0_qpllrefclklost_in
    .gt0_qpllreset_out              (w_gt0_qpllreset        ), // output wire gt0_qpllreset_out
    .gt0_qplloutclk_in              (i_gt0_qplloutclk       ), // input wire gt0_qplloutclk_in
    .gt0_qplloutrefclk_in           (i_gt0_qplloutrefclk    ) // input wire gt0_qplloutrefclk_in
);


endmodule
