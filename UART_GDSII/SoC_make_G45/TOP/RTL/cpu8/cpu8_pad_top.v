`timescale 1ns/1ps
`default_nettype none
// Signal-pad wrapper for a standalone CPU8 chip boundary.
// Use cpu8_top directly when its buses connect to memory/UART inside an SoC.
// Power/ground pads belong to the eventual floorplan, as in cmsdk_mcu.v.
module cpu8_pad_top (
    input wire i_clk,
    input wire i_rst_n,
    output wire [16:0] o_i_haddr,
    output wire [1:0] o_i_htrans,
    output wire [2:0] o_i_hsize,
    output wire [2:0] o_i_hburst,
    output wire [3:0] o_i_hprot,
    output wire o_i_hwrite,
    output wire o_i_hmastlock,
    input wire [15:0] i_i_hrdata,
    input wire i_i_hready,
    input wire i_i_hresp,
    output wire [15:0] o_d_haddr,
    output wire [1:0] o_d_htrans,
    output wire [2:0] o_d_hsize,
    output wire [2:0] o_d_hburst,
    output wire [3:0] o_d_hprot,
    output wire o_d_hwrite,
    output wire o_d_hmastlock,
    output wire [7:0] o_d_hwdata,
    input wire [7:0] i_d_hrdata,
    input wire i_d_hready,
    input wire i_d_hresp,
    input wire i_irq,
    output wire o_halted,
    output wire o_fault,
    output wire [2:0] o_fault_code,
    output wire [15:0] o_pc,
    output wire [15:0] o_x,
    output wire [3:0] o_flags,
    output wire [31:0] o_registers,
    output wire o_stall,
    output wire [2:0] o_stage_valid,
    output wire o_retire_valid,
    output wire [15:0] o_retire_pc,
    output wire [15:0] o_retire_instruction,
    output wire o_retire_reg_write,
    output wire [1:0] o_retire_rd,
    output wire [7:0] o_retire_data,
    output wire o_retire_bank,
    output wire o_irq_active
);

    wire w_i_clk;
    wire w_i_rst_n;
    wire [16:0] w_o_i_haddr;
    wire [1:0] w_o_i_htrans;
    wire [2:0] w_o_i_hsize;
    wire [2:0] w_o_i_hburst;
    wire [3:0] w_o_i_hprot;
    wire w_o_i_hwrite;
    wire w_o_i_hmastlock;
    wire [15:0] w_i_i_hrdata;
    wire w_i_i_hready;
    wire w_i_i_hresp;
    wire [15:0] w_o_d_haddr;
    wire [1:0] w_o_d_htrans;
    wire [2:0] w_o_d_hsize;
    wire [2:0] w_o_d_hburst;
    wire [3:0] w_o_d_hprot;
    wire w_o_d_hwrite;
    wire w_o_d_hmastlock;
    wire [7:0] w_o_d_hwdata;
    wire [7:0] w_i_d_hrdata;
    wire w_i_d_hready;
    wire w_i_d_hresp;
    wire w_i_irq;
    wire w_o_halted;
    wire w_o_fault;
    wire [2:0] w_o_fault_code;
    wire [15:0] w_o_pc;
    wire [15:0] w_o_x;
    wire [3:0] w_o_flags;
    wire [31:0] w_o_registers;
    wire w_o_stall;
    wire [2:0] w_o_stage_valid;
    wire w_o_retire_valid;
    wire [15:0] w_o_retire_pc;
    wire [15:0] w_o_retire_instruction;
    wire w_o_retire_reg_write;
    wire [1:0] w_o_retire_rd;
    wire [7:0] w_o_retire_data;
    wire w_o_retire_bank;
    wire w_o_irq_active;

    PADDI u_pad_i_clk (.PAD(i_clk), .Y(w_i_clk));

    PADDI u_pad_i_rst_n (.PAD(i_rst_n), .Y(w_i_rst_n));

    genvar g_o_i_haddr;
    generate
        for (g_o_i_haddr = 0; g_o_i_haddr < 17; g_o_i_haddr = g_o_i_haddr + 1) begin : gen_pad_o_i_haddr
            PADDO u_pad (.A(w_o_i_haddr[g_o_i_haddr]), .PAD(o_i_haddr[g_o_i_haddr]));
        end
    endgenerate

    genvar g_o_i_htrans;
    generate
        for (g_o_i_htrans = 0; g_o_i_htrans < 2; g_o_i_htrans = g_o_i_htrans + 1) begin : gen_pad_o_i_htrans
            PADDO u_pad (.A(w_o_i_htrans[g_o_i_htrans]), .PAD(o_i_htrans[g_o_i_htrans]));
        end
    endgenerate

    genvar g_o_i_hsize;
    generate
        for (g_o_i_hsize = 0; g_o_i_hsize < 3; g_o_i_hsize = g_o_i_hsize + 1) begin : gen_pad_o_i_hsize
            PADDO u_pad (.A(w_o_i_hsize[g_o_i_hsize]), .PAD(o_i_hsize[g_o_i_hsize]));
        end
    endgenerate

    genvar g_o_i_hburst;
    generate
        for (g_o_i_hburst = 0; g_o_i_hburst < 3; g_o_i_hburst = g_o_i_hburst + 1) begin : gen_pad_o_i_hburst
            PADDO u_pad (.A(w_o_i_hburst[g_o_i_hburst]), .PAD(o_i_hburst[g_o_i_hburst]));
        end
    endgenerate

    genvar g_o_i_hprot;
    generate
        for (g_o_i_hprot = 0; g_o_i_hprot < 4; g_o_i_hprot = g_o_i_hprot + 1) begin : gen_pad_o_i_hprot
            PADDO u_pad (.A(w_o_i_hprot[g_o_i_hprot]), .PAD(o_i_hprot[g_o_i_hprot]));
        end
    endgenerate

    PADDO u_pad_o_i_hwrite (.A(w_o_i_hwrite), .PAD(o_i_hwrite));

    PADDO u_pad_o_i_hmastlock (.A(w_o_i_hmastlock), .PAD(o_i_hmastlock));

    genvar g_i_i_hrdata;
    generate
        for (g_i_i_hrdata = 0; g_i_i_hrdata < 16; g_i_i_hrdata = g_i_i_hrdata + 1) begin : gen_pad_i_i_hrdata
            PADDI u_pad (.PAD(i_i_hrdata[g_i_i_hrdata]), .Y(w_i_i_hrdata[g_i_i_hrdata]));
        end
    endgenerate

    PADDI u_pad_i_i_hready (.PAD(i_i_hready), .Y(w_i_i_hready));

    PADDI u_pad_i_i_hresp (.PAD(i_i_hresp), .Y(w_i_i_hresp));

    genvar g_o_d_haddr;
    generate
        for (g_o_d_haddr = 0; g_o_d_haddr < 16; g_o_d_haddr = g_o_d_haddr + 1) begin : gen_pad_o_d_haddr
            PADDO u_pad (.A(w_o_d_haddr[g_o_d_haddr]), .PAD(o_d_haddr[g_o_d_haddr]));
        end
    endgenerate

    genvar g_o_d_htrans;
    generate
        for (g_o_d_htrans = 0; g_o_d_htrans < 2; g_o_d_htrans = g_o_d_htrans + 1) begin : gen_pad_o_d_htrans
            PADDO u_pad (.A(w_o_d_htrans[g_o_d_htrans]), .PAD(o_d_htrans[g_o_d_htrans]));
        end
    endgenerate

    genvar g_o_d_hsize;
    generate
        for (g_o_d_hsize = 0; g_o_d_hsize < 3; g_o_d_hsize = g_o_d_hsize + 1) begin : gen_pad_o_d_hsize
            PADDO u_pad (.A(w_o_d_hsize[g_o_d_hsize]), .PAD(o_d_hsize[g_o_d_hsize]));
        end
    endgenerate

    genvar g_o_d_hburst;
    generate
        for (g_o_d_hburst = 0; g_o_d_hburst < 3; g_o_d_hburst = g_o_d_hburst + 1) begin : gen_pad_o_d_hburst
            PADDO u_pad (.A(w_o_d_hburst[g_o_d_hburst]), .PAD(o_d_hburst[g_o_d_hburst]));
        end
    endgenerate

    genvar g_o_d_hprot;
    generate
        for (g_o_d_hprot = 0; g_o_d_hprot < 4; g_o_d_hprot = g_o_d_hprot + 1) begin : gen_pad_o_d_hprot
            PADDO u_pad (.A(w_o_d_hprot[g_o_d_hprot]), .PAD(o_d_hprot[g_o_d_hprot]));
        end
    endgenerate

    PADDO u_pad_o_d_hwrite (.A(w_o_d_hwrite), .PAD(o_d_hwrite));

    PADDO u_pad_o_d_hmastlock (.A(w_o_d_hmastlock), .PAD(o_d_hmastlock));

    genvar g_o_d_hwdata;
    generate
        for (g_o_d_hwdata = 0; g_o_d_hwdata < 8; g_o_d_hwdata = g_o_d_hwdata + 1) begin : gen_pad_o_d_hwdata
            PADDO u_pad (.A(w_o_d_hwdata[g_o_d_hwdata]), .PAD(o_d_hwdata[g_o_d_hwdata]));
        end
    endgenerate

    genvar g_i_d_hrdata;
    generate
        for (g_i_d_hrdata = 0; g_i_d_hrdata < 8; g_i_d_hrdata = g_i_d_hrdata + 1) begin : gen_pad_i_d_hrdata
            PADDI u_pad (.PAD(i_d_hrdata[g_i_d_hrdata]), .Y(w_i_d_hrdata[g_i_d_hrdata]));
        end
    endgenerate

    PADDI u_pad_i_d_hready (.PAD(i_d_hready), .Y(w_i_d_hready));

    PADDI u_pad_i_d_hresp (.PAD(i_d_hresp), .Y(w_i_d_hresp));

    PADDI u_pad_i_irq (.PAD(i_irq), .Y(w_i_irq));

    PADDO u_pad_o_halted (.A(w_o_halted), .PAD(o_halted));

    PADDO u_pad_o_fault (.A(w_o_fault), .PAD(o_fault));

    genvar g_o_fault_code;
    generate
        for (g_o_fault_code = 0; g_o_fault_code < 3; g_o_fault_code = g_o_fault_code + 1) begin : gen_pad_o_fault_code
            PADDO u_pad (.A(w_o_fault_code[g_o_fault_code]), .PAD(o_fault_code[g_o_fault_code]));
        end
    endgenerate

    genvar g_o_pc;
    generate
        for (g_o_pc = 0; g_o_pc < 16; g_o_pc = g_o_pc + 1) begin : gen_pad_o_pc
            PADDO u_pad (.A(w_o_pc[g_o_pc]), .PAD(o_pc[g_o_pc]));
        end
    endgenerate

    genvar g_o_x;
    generate
        for (g_o_x = 0; g_o_x < 16; g_o_x = g_o_x + 1) begin : gen_pad_o_x
            PADDO u_pad (.A(w_o_x[g_o_x]), .PAD(o_x[g_o_x]));
        end
    endgenerate

    genvar g_o_flags;
    generate
        for (g_o_flags = 0; g_o_flags < 4; g_o_flags = g_o_flags + 1) begin : gen_pad_o_flags
            PADDO u_pad (.A(w_o_flags[g_o_flags]), .PAD(o_flags[g_o_flags]));
        end
    endgenerate

    genvar g_o_registers;
    generate
        for (g_o_registers = 0; g_o_registers < 32; g_o_registers = g_o_registers + 1) begin : gen_pad_o_registers
            PADDO u_pad (.A(w_o_registers[g_o_registers]), .PAD(o_registers[g_o_registers]));
        end
    endgenerate

    PADDO u_pad_o_stall (.A(w_o_stall), .PAD(o_stall));

    genvar g_o_stage_valid;
    generate
        for (g_o_stage_valid = 0; g_o_stage_valid < 3; g_o_stage_valid = g_o_stage_valid + 1) begin : gen_pad_o_stage_valid
            PADDO u_pad (.A(w_o_stage_valid[g_o_stage_valid]), .PAD(o_stage_valid[g_o_stage_valid]));
        end
    endgenerate

    PADDO u_pad_o_retire_valid (.A(w_o_retire_valid), .PAD(o_retire_valid));

    genvar g_o_retire_pc;
    generate
        for (g_o_retire_pc = 0; g_o_retire_pc < 16; g_o_retire_pc = g_o_retire_pc + 1) begin : gen_pad_o_retire_pc
            PADDO u_pad (.A(w_o_retire_pc[g_o_retire_pc]), .PAD(o_retire_pc[g_o_retire_pc]));
        end
    endgenerate

    genvar g_o_retire_instruction;
    generate
        for (g_o_retire_instruction = 0; g_o_retire_instruction < 16; g_o_retire_instruction = g_o_retire_instruction + 1) begin : gen_pad_o_retire_instruction
            PADDO u_pad (.A(w_o_retire_instruction[g_o_retire_instruction]), .PAD(o_retire_instruction[g_o_retire_instruction]));
        end
    endgenerate

    PADDO u_pad_o_retire_reg_write (.A(w_o_retire_reg_write), .PAD(o_retire_reg_write));

    genvar g_o_retire_rd;
    generate
        for (g_o_retire_rd = 0; g_o_retire_rd < 2; g_o_retire_rd = g_o_retire_rd + 1) begin : gen_pad_o_retire_rd
            PADDO u_pad (.A(w_o_retire_rd[g_o_retire_rd]), .PAD(o_retire_rd[g_o_retire_rd]));
        end
    endgenerate

    genvar g_o_retire_data;
    generate
        for (g_o_retire_data = 0; g_o_retire_data < 8; g_o_retire_data = g_o_retire_data + 1) begin : gen_pad_o_retire_data
            PADDO u_pad (.A(w_o_retire_data[g_o_retire_data]), .PAD(o_retire_data[g_o_retire_data]));
        end
    endgenerate

    PADDO u_pad_o_retire_bank (.A(w_o_retire_bank), .PAD(o_retire_bank));

    PADDO u_pad_o_irq_active (.A(w_o_irq_active), .PAD(o_irq_active));

    cpu8_top u_cpu8 (
        .i_clk(w_i_clk),
        .i_rst_n(w_i_rst_n),
        .o_i_haddr(w_o_i_haddr),
        .o_i_htrans(w_o_i_htrans),
        .o_i_hsize(w_o_i_hsize),
        .o_i_hburst(w_o_i_hburst),
        .o_i_hprot(w_o_i_hprot),
        .o_i_hwrite(w_o_i_hwrite),
        .o_i_hmastlock(w_o_i_hmastlock),
        .i_i_hrdata(w_i_i_hrdata),
        .i_i_hready(w_i_i_hready),
        .i_i_hresp(w_i_i_hresp),
        .o_d_haddr(w_o_d_haddr),
        .o_d_htrans(w_o_d_htrans),
        .o_d_hsize(w_o_d_hsize),
        .o_d_hburst(w_o_d_hburst),
        .o_d_hprot(w_o_d_hprot),
        .o_d_hwrite(w_o_d_hwrite),
        .o_d_hmastlock(w_o_d_hmastlock),
        .o_d_hwdata(w_o_d_hwdata),
        .i_d_hrdata(w_i_d_hrdata),
        .i_d_hready(w_i_d_hready),
        .i_d_hresp(w_i_d_hresp),
        .i_irq(w_i_irq),
        .o_halted(w_o_halted),
        .o_fault(w_o_fault),
        .o_fault_code(w_o_fault_code),
        .o_pc(w_o_pc),
        .o_x(w_o_x),
        .o_flags(w_o_flags),
        .o_registers(w_o_registers),
        .o_stall(w_o_stall),
        .o_stage_valid(w_o_stage_valid),
        .o_retire_valid(w_o_retire_valid),
        .o_retire_pc(w_o_retire_pc),
        .o_retire_instruction(w_o_retire_instruction),
        .o_retire_reg_write(w_o_retire_reg_write),
        .o_retire_rd(w_o_retire_rd),
        .o_retire_data(w_o_retire_data),
        .o_retire_bank(w_o_retire_bank),
        .o_irq_active(w_o_irq_active)
    );
endmodule
`default_nettype wire
