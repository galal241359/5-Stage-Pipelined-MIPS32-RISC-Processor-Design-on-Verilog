module mips_top(
    input clk,
    input rst,
    output [31:0] pc,
    output [31:0] instr,
    output [31:0] alu_result,
    output [31:0] read_data1,
    output [31:0] read_data2,
    output [31:0] write_data,
    output [31:0] pc_next,
    output reg_dst,
    output reg_write,
    output alu_src,
    output mem_to_reg,
    output mem_write,
    output branch
);

    wire [31:0] pc_plus_4;
    wire [31:0] sign_imm;
    wire [31:0] branch_target;
    wire [31:0] pc_target;
    wire [31:0] alu_b;
    wire [31:0] mem_read_data;
    wire [4:0] write_reg;
    wire [2:0] alu_control;
    wire zero;
    wire pc_src;

    assign pc_src = branch & zero;
    assign pc_plus_4 = pc + 32'd4;
    assign sign_imm = {{16{instr[15]}}, instr[15:0]};
    assign branch_target = pc_plus_4 + (sign_imm << 2);
    assign alu_b = alu_src ? sign_imm : read_data2;
    assign write_reg = reg_dst ? instr[15:11] : instr[20:16];
    assign write_data = mem_to_reg ? mem_read_data : alu_result;
    assign pc_target = pc_src ? branch_target : pc_plus_4;

    pc_register pc_reg(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_target),
        .pc(pc)
    );

    instruction_memory imem(
        .pc(pc),
        .instr(instr)
    );

    register_file rf(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(instr[25:21]),
        .read_reg2(instr[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    control_unit cu(
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op()
    );

    alu_control ac(
        .alu_op(2'b10),
        .funct(instr[5:0]),
        .alu_control(alu_control)
    );

    alu main_alu(
        .a(read_data1),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    data_memory dmem(
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

endmodule