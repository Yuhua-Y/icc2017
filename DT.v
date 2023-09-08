module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output	reg		sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		[15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

	reg [3:0]cur_st,next_st;
	parameter IDLE =4'd0,STI_READ=4'd1 ,OBJ_BG=4'd2 ,RES_READ=4'd3 ,FRONT_CALC=4'd4 ,WRITE=4'd5,RES_READ2=4'd6,WRITE2=4'd7,FINISH=4'd8;
	
	reg [13:0]counter_addr;
	reg [13:0]counter_addr1;
	reg [15:0]sti_data;
	wire [3:0]site;
	wire obj_bg;
	assign obj_bg=sti_data[site];
	assign site=15-counter_addr[3:0];//the order
	
	reg front_end;//FRONT_CALC end 
	reg res;
	reg [7:0]res_data,res_data1;
	reg [2:0]counter_5;
	reg [7:0]min_data;

	always @(posedge clk or negedge reset) begin
		if(~reset)
			cur_st<=IDLE;
		else
			cur_st<=next_st;
	end

	always @(*) begin
		case(cur_st)
			IDLE:next_st=(reset)?STI_READ:IDLE;
			STI_READ:next_st=(counter_addr>256)?OBJ_BG:WRITE;
			OBJ_BG:next_st=(obj_bg)?RES_READ:WRITE;
			RES_READ:next_st=(counter_5==5)?FRONT_CALC:RES_READ;
			FRONT_CALC:next_st=WRITE;
			WRITE:next_st=(front_end)?RES_READ2:(site==0)?STI_READ:(counter_addr<256)?WRITE:OBJ_BG;
			RES_READ2:next_st=((counter_5==5)||((counter_5==1)&&(res_data==0)))?WRITE2:RES_READ2;//DEFINE OBG BG
			WRITE2:next_st=(counter_addr1==128)?FINISH:RES_READ2;
			FINISH:next_st=FINISH;
			default:next_st=IDLE;
		endcase
	end
	
	//res_wr
	always @(*) begin
		if(~reset)
			res_wr=0;
		else if((cur_st==WRITE)||(cur_st==WRITE2))
			res_wr=1;
		else 
			res_wr=0;
	end

	//res_rd
	always @(*) begin
		if(~reset)
			res_rd=0;
		else if((cur_st==RES_READ)||(cur_st==RES_READ2))
			res_rd=1;
		else 
			res_rd=0;
	end

	//counter_addr
	always @(posedge clk or negedge reset) begin
		if(~reset)
			counter_addr<=0;
		else if(cur_st==WRITE)
			counter_addr<=counter_addr+1;
		else 
			counter_addr<=counter_addr;
	end

	always @(posedge clk or negedge reset) begin
		if(~reset)
			counter_addr1<=16254;
		else if(cur_st==WRITE2)
			counter_addr1<=counter_addr1-1;
	end
	
	//sti_rd
	always @(*) begin
		if(~reset)
			sti_rd=0;
		else if(cur_st==STI_READ)
			sti_rd=1;
		else
			sti_rd=0;
	end

	//sti_addr
	always @(*) begin
		if(~reset)
			sti_addr=0;
		else if(cur_st==STI_READ)
			sti_addr=counter_addr[13:4];	
		else 
			sti_addr=0;
	end

	//sti_data
	always @(posedge clk or negedge reset) begin
		if(~reset)
			sti_data<=0;
		else if(cur_st==STI_READ)begin
			sti_data<=sti_di;  
		end
	end

	//front_end
	always @(posedge clk or negedge reset) begin
		if(~reset)
			front_end<=0;
		else if(counter_addr==16383)
			front_end<=1;
	end

	//counter_5
	always @(posedge clk or negedge reset) begin
		if(~reset)
			counter_5<=0;
		else if((cur_st==RES_READ)||(cur_st==RES_READ2))
			counter_5<=counter_5+1;
		else
			counter_5<=0;
	end

	//res_addr
	always @(*) begin
		if(~reset)
			res_addr=0;
		else if ((cur_st==RES_READ)&(~front_end)) begin
			case (counter_5)
				0:res_addr=counter_addr-129;
				1:res_addr=counter_addr-128;
				2:res_addr=counter_addr-127;
				3:res_addr=counter_addr-1;
				default:res_addr=0;
			endcase
		end
		else if(cur_st==WRITE)
			res_addr=counter_addr;
		else if(cur_st==RES_READ2)begin
			case (counter_5)
				0:res_addr=counter_addr1;
				1:res_addr=counter_addr1+1;
				2:res_addr=counter_addr1+127;
				3:res_addr=counter_addr1+128;
				4:res_addr=counter_addr1+129;
				default:res_addr=0;
			endcase
		end
		else if(cur_st==WRITE2)
			res_addr=counter_addr1;
		else 
			res_addr=0;
	end

	always @(posedge clk or negedge reset) begin
		if(~reset)
			res<=0;
		else if((cur_st==RES_READ)||(cur_st==RES_READ2))
			res<=res+1;
		else
			res<=0;
	end
	
	//res_data
	always @(posedge clk or negedge reset) begin
		if(~reset)
			res_data<=0;
		else if(cur_st==RES_READ)begin
			if(~res)	
				res_data<=res_di;	
			end
		else if(cur_st==RES_READ2)begin
			if(counter_5==0)
				res_data<=res_di;
			else if(~res)
				res_data<=res_di+1;
		end
	end

	//res_data1
	always @(posedge clk or negedge reset) begin
		if(~reset)
			res_data1<=0;
		else if(cur_st==RES_READ)begin
			if(res)
				res_data1<=res_di;	
		end
		else if(cur_st==RES_READ2)begin
			if(res)
				res_data1<=res_di+1;
		end
	end

	//min_data
	always @(posedge clk or negedge reset) begin
		if(~reset)
			min_data<=0;
		else if((cur_st==RES_READ)&(~front_end))begin
			case(counter_5)
			1:min_data<=res_data;
			2:min_data<=min(min_data,res_data1);
			3:min_data<=min(min_data,res_data);
			4:min_data<=min(min_data,res_data1);
			endcase 
		end
		else if(cur_st==RES_READ2)begin
			case(counter_5)
			1:min_data<=res_data;//res_data
			2:min_data<=min(min_data,res_data1);
			3:min_data<=min(min_data,res_data);
			4:min_data<=min(min_data,res_data1);
			5:min_data<=min(min_data,res_data);
			default:min_data<=255;
			endcase
		end
	end

	//res_do
	always @(*) begin
		if(cur_st==WRITE)begin
			if(sti_data[site]==0)
				res_do=0;
			else if(counter_addr<256)
				res_do=1;
			else
				res_do=min_data+1;
		end
		else if(cur_st==WRITE2)
			res_do=min_data;
		else
			res_do=0;
	end

	always @(*) begin
		if(cur_st==FINISH)
			done=1;
		else
			done=0;
	end

	function [7:0]min;
		input [7:0]a,b;
		begin
			 min=(a>b)?b:a;
		end
		
	endfunction

endmodule