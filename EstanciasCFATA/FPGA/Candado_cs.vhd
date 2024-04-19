--Candado simple con borrado sincrono
library IEEE;
use IEEE.std_logic_1164.all;

entity Candado_cs is
	port(
		D  : in  std_logic; --Entrada datos 
		LD	: in  std_logic; --Carga datos
		Clr: in  std_logic; --Borrado 
		Q	: out std_logic  --Salida
	);
	end Candado_cs;

architecture Simple of Candado_cs is 
	begin
		process(D, LD, Clr)
			begin 
				if (LD='0') then 
					if (CLe='0')then
						Q <= '0';
				else
					Q <= D;
				end if;
			end process;
		end Simple;
	
