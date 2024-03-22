--Mux 2-1 con asignación condicional
library IEEE;
use IEEE.std_logic_1164.all; --Libreria estandar

-- Black box

entity Mux_2_1 is 
	port(
		I: in std_logic_vector(1 downto 0); --Entradas (2)
		S: in std_logic;
		Y: out std_logic
		);
	end Mux_2_1;
	
-- Descripción del circuito 
architecture simple of Mux_2_1 is 
	begin 
		Y <= I(0) when (S='0') else I(1); --Asignacion condicional
	end simple;

-- variable <= asignación_ 1 when condicion else asignación_2;
