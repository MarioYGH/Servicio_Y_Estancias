--Mux 2-1 con asignación condicional con estructura if 
library IEEE;
use IEEE.std_logic_1164.all; --Libreria estandar

-- Black box

entity Mux_2_1_if is 
	port(
		I: in std_logic_vector(1 downto 0); --Entradas (2)
		S: in std_logic;							--Seleccion
		Y: out std_logic							--Salidad
		);
	end Mux_2_1_if;
	
-- Descripción del circuito 

architecture simple of Mux_2_1_if is 
	begin 
		process(S,I)
			begin
				if S='0' then --Inicio if
					Y <= I(0); --Asignacion para S=0
				else 
					Y <= I(1); --Asignacion para S=1
				end if;
			end process;
	end simple;
