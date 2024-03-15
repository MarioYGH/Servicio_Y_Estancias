-- Se subio con exito este programa al FPGA, los pines los encuentras en el manual de usuario 
library IEEE;
use IEEE.std_logic_1164.all; -- Libreria estandar 
use IEEE.std_logic_arith.all; --It allows you to perform arithmetic operations on these types, including addition, subtraction, multiplication, and division.
use IEEE.std_logic_unsigned.all; --  proporciona operaciones y funciones para manipular tipos de datos std_logic_vector de manera similar a cómo se manipularían los tipos de datos enteros sin signo.
-- En foros se recomienda utilizar IEEE.std_logic_arith.all, para reemplazar las dos librerias anteriores

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
