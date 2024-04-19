--Flip-flop tipo D de borde de disparo positivo
library IEEE;
use IEEE.std_logic_1164.all;

entity Flip_flop_d is
	port(
		D  : in  std_logic; --Entrada datos 
		Clk: in  std_logic; --Reloj 
		Q	: out std_logic  --Salida
	);
	end Flip_flop_d;

architecture Simple of Flip_flop_d is 
	begin
		process(Clk)
			begin 
				if (Clk'event and Clk='1') then  --Si se desea tener un borde de disparo negativo se debe cambiar la condicion Clk='0'
						Q <= D;
				else
					Q <= D;
				end if;
			end process;
		end Simple;
	
