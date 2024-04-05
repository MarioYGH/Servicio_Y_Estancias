library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Mux_4_1 is 
port(
	I : in std_logic_vector(3 downto 0); --Entradas
	S : in std_logic_vector(1 downto 0); --Seleccion
	Y : out std_logic --Salida
	);
end Mux_4_1;
--Descripción circuito 

architecture simple of Mux_4_1 is 
	begin 
		process(S,I) --Declaración del proceso 
			begin 
				case S is --Declaracion del case
					when "00" => Y <= I(0); --Asignacion para S=00
					when "01" => Y <= I(1); --Asignacion para S=01
					when "10" => Y <= I(2); --Asignacion para S=10
					when others => Y <= I(3); --Asignacion para S=11
				end case;
			end process;
		end simple; 
