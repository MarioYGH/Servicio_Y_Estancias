--A difrencia de los circuitos combinacionales en el que las salidas dependen directamente de las entradas,
--En un circuito secuencial depende de la secuencia de las entradas y los parámetros deseados
--Primer máquina de Estado finita sincrónica
library IEEE;
use IEEE.std_logic_1164.all;

entity cerradura is 
	port(
		rst,clk :in std_logic;
		A,B,C   :in std_logic;
		Z       :out std_logic
	);
end entity cerradura;

architecture A1 of cerradura is
	type tipo_estado is(uno,dos,tres,cuatro,cinco); --Señales definidas como tipo estado
	signal estado_actual,proximo_estado:tipo_estado; --Las variables definidas como tipo estado solo podran tomar esos valores
begin 
	estado_act_prox: process(estado_actual,A,B,C)
	begin 
		case estado_actual is 
		 when uno =>
			if A ='0' and B ='0' and C ='1' then
				proximo_estado <= dos;
			else 
				proximo_estado <= uno;
			end if;
		 when dos =>
			if A ='1' and B ='0' and C ='0' then
				proximo_estado <= tres;
			elsif A ='0' and B ='0' and C ='1' then
				proximo_estado <= dos;
			else 
				proximo_estado <= uno;
			end if;
		  when tres =>
			if A ='1' and B ='0' and C ='1' then
				proximo_estado <= cuatro;
			elsif A ='1' and B ='0' and C ='0' then
				proximo_estado <= tres;
			else 
				proximo_estado <= uno;
			end if;
		  when cuatro =>
			if A ='1' and B ='1' and C ='1' then
				proximo_estado <= cinco;
			elsif A ='1' and B ='0' and C ='1' then
				proximo_estado <= cuatro;
			else 
				proximo_estado <= uno;
			end if;
		  when cinco =>
			if A ='1' and B ='1' and C ='1' then
				proximo_estado <= cinco;
			else 
				proximo_estado <= uno;
			end if;
		 end case;
		end process;
		
registro:process(rst,clk)
begin
	if rst='1'then
		estado_actual <= uno;
	elsif clk'event and clk = '1' then
		estado_actual <=	proximo_estado;
	end if;
end process;

Z <= '1' when estado_actual = cinco else 
     '0';
end architecture A1;
			
			


