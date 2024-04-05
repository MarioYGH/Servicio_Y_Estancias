library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Demux_2_4 is 
port(
	X : in  std_logic; --Entradas
	S : in  std_logic_vector(1 downto 0); --Seleccion
	Y : out std_logic_vector(3 downto 0); --Salida
	);
--Descripción circuito 

architecture cuadruple of Demux_2_4 is 
	begin 
		process(X,S) --Declaración del proceso 
			begin 
        Y <= "0000" --Valores por omision
				case S is --Declaracion del case
					when "00" => Y <= X; --Asignacion concurrente
					when "01" => Y <= X; --Asignacion concurrente
					when "10" => Y <= X; --Asignacion concurrente
					when others => Y <= X; --Asignacion concurrente
				end case;
			end process;
		end cuadruple; 
