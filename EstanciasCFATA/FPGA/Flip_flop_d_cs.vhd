--Flio-flop tipo d con borrado asincrono
library IEEE;
use IEEE.std_logic_1164.all;

entity Flip_flop_d_cs is
	port(
		D  : in  std_logic; --Entrada datos 
		Clk: in  std_logic; --Reloj 
		Clr: in  std_logic; --Borrado
		Q	: out std_logic  --Salida
	);
	end Flip_flop_d_cs;

architecture Simple of Flip_flop_d_cs is 
	begin
		process(Clk, Clr)
			begin
				if (Clr='0') then 
					Q <= '0';
				elsif (Clk'event and Clk='1') then 
					Q <= D;
				end if;
			end process;
		end Simple;
	
