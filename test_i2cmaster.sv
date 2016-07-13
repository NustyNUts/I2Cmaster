//простой тест для получения выходных временых диаграмм
`timescale 10ns/10ns
module test_i2c();

bit clk;
bit[7:0] data;
bit SDA_out;
bit SCL_out;
bit start;
bit reset;
int clkTime;
int i;
int j;
master_i2c uut(clk,data,reset,start,SDA_out,SCL_out);
initial begin
clkTime = 5;
data = 8'b10101010;
start=0;
reset = 0;

#clkTime
	reset=1;
	clk=~clk;
	#clkTime
	reset=0;
	clk=~clk;


j=99;
while(j--)
begin
data = j;
	#clkTime
	start=1;
	clk=~clk;
	#clkTime
	clk=~clk;
i=40;	
	while(i--) begin
		#clkTime
		clk=~clk;
		#clkTime
		clk=~clk;
		start=0;
	end
end
end

endmodule
