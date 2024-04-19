--Candado simple
--Candado que se activa con un nivel alto en la terminal LD y la información de D pasa a Q. 
--Una vez el estado inactivo, la salida Q mantiene si estado aunque haya cambios en D 
library IEEE;
use IEEE.std_logic_1164.all;

entity Candado is
	port(
		D  : in  std_logic; --Entrada datos 
		LD	: in  std_logic; --Carga datos
		Q	: out std_logic  --Salida
	);
	end Candado;

architecture Simple of Candado is 
	begin
		process(D, LD)
			begin 
				if (LD='1') then
					Q <= D;
				end if;
			end process;
		end Simple;
	
