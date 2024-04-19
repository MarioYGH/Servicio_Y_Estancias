--Candado simple con borrado asincrono
library IEEE;
use IEEE.std_logic_1164.all;

entity Candado_c is
	port(
		D  : in  std_logic; --Entrada datos 
		LD	: in  std_logic; --Carga datos
		Clr: in  std_logic; --Borrado 
		Q	: out std_logic  --Salida
	);
	end Candado_c;

architecture Simple of Candado_c is 
	begin
		process(D, LD, Clr)
			begin 
				if (Clr='0') then 
					Q <= '0';
				elsif (LD='1') then
					Q <= D;
				end if;
			end process;
		end Simple;
	
