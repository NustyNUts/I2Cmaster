

module master_i2c(clk,inData,reset,start,SDA,SCL);
	parameter size = 8;
	input	 wire clk;
	input wire [size-1:0]inData;
	input wire reset;
	input wire start;
	output reg  SDA;//SDA - данные
	output reg	SCL ; //SCL - синхроимпульс
	
	reg [4:0]i;//счетчик для передачи данных
	reg [7:0] data;
	// Declare state register
	reg		[1:0]state;
	reg [1:0]temp;//регистр состояний операций
	// декларация состояний автомата
	parameter S0 = 0, S1 = 1, S2 = 2;
initial begin
	SDA=1;
	SCL=1;
	i=0;
	temp=0;
end


	//S0 - начало передачи
	//S1 - передача
	//S2 - конец передачи
	always @ (posedge clk or posedge reset) begin

		if (reset)
			state <= S0;//по ресету переходим в состояние ожидания старта
		else
			case (state)
				S0://старт
					if (start)
					begin
						data <= inData;//сохраняем данные с шины в регистр
						SDA <= 0;//инициируем передачу
						state <= S1;//переводим автомат в состояние передачи
						i<=0;
						temp<=0;
					end
					else
					begin//ждем старта, держим SDA и SCL  в 1
						SDA <= 1;
						SCL <= 1;
						temp <= 0;
						state <= S0;// остаемся в этом состоянии
					end
					//--------------
				S1://передача
					if (i==size+1)//все ли биты передали
					begin//переход в стоп
					//подготавливаем линию данных и синхроимпульсов для состояния стоп
						SDA<=0;
						SCL<=0;
						//--------------
						i<=0;
						state <= S2;//переходим в стостояние стоп
						temp <=0;
					end
					else
					begin//передаем
						case(temp)
						0:
							begin
								SCL <=0;//SCL в 0, можем писать в SDA
								if(i<size)
									SDA <= data[i];//выставление i-го бита для отправки
								else 
									SDA =0 ;
								i <= i+1;
							end
						1:
							SCL <=1;//отправка i-го бита
						2:
							SCL <=1;
						3:
							SCL <= 0;//сбрасываем в 0 тактовый сигнал
						endcase
						temp <= temp+1;
						state <= S1;//остаемся в этом же состоянии
					end
					//--------------
				S2://стоп
					if (temp == 3)//получили положительный фронт SDA при высоком уровне SCL,
					begin
					//	подготавливаем к состоянию ожидания данных
						SDA <= 1;
						SCL <=1;	
						//----------------------
						state <= S0;//переход в состояние ожидания данных
					end
					else
					begin
					case(temp)//выбор текущей операции
					0://подготовка линии данных
						SDA <= 0;
					1://подготовка линии синхроимпульсов
						SCL <= 1;
					2:
						SDA <= 1;//получение положительного фронта SDA 
						endcase
						state <= S2;//остаемся в этом состоянии
						temp = temp+1;//переходим к следующей операции
					end
					//--------------
			endcase
	end
endmodule
