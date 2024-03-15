library IEEE;
use ieee.std_logic_1164.all; -- Libreria estandar 

entity funcion_y_z is
	port (
		A: in std_logic;
		B: in std_logic;
		C: in std_logic;
		Z: out std_logic;
		Y: out std_logic  -- La última línea de las variables no lleva ; no se muy bien pq
	);
end entity funcion_y_z;

architecture A1 of funcion_y_z is 
begin 
		Y <= NOT((A OR C) XOR B);
		Z <= (A AND B) OR (A OR C);
end architecture A1;

-- Para verificar que la compuerta se creo correctamente, dar click en tool, netlist viewers y RTL viewer
