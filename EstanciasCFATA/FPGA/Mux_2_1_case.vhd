--Mux 2-1 con estructura case
library IEEE;
use IEEE.std_logic_1164.all; --Libreria estandar

-- Black box

entity Mux_2_1_case is 
	port(
		I: in std_logic_vector(1 downto 0); --Entradas (2)
		S: in std_logic;
		Y: out std_logic
		);
	end Mux_2_1_case;
	
-- Descripción del circuito 
architecture simple of Mux_2_1 is 
	begin 
		process(S,I) --Declaración del proceso
			begin
				case S is --Declaración del case
					when '0' => Y <= I(0); --Asignación para S=0
					when others => Y <= I(1); /*Asignacion S=1*/
					end case; --Fin del case
			end process; --Fin del proceso
		end simple;
/*
--Forma general del case
case variable is 
when opcion1 => grupo de asignaciones1;
when opcion2 => grupo de asignaciones2; 
...
when others => grupo de asignaciones por omision;
end case;

--Forma estructura process
process(lista_de_sensitividades)
	begin 
		asignaciones_secuenciales;
	end process;
	*/
	
