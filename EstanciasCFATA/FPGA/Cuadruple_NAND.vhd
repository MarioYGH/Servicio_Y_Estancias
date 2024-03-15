-- La asignación directa de la línea 16 hacer que el circuito resultante sean 4 compuertas NAND de dos entradas, de tal forma que 
-- F(1) <= A(1) NAND B(1), F(2) <= A(2) NAND B(2) y así sucesivamente, las asignaciones directas solo pueden realizarse entre variables
-- del mismo tipo, es decir n con n, bit a bit , vector de tamaño n a vector de tamaño n.
library IEEE;
use ieee.std_logic_1164.all -- Libreria estandar 

entity Cuadruple_NAND is
	port (
     A, B : in std_logic_vector(1 to 4); -- 4 Entradas simples
     F    : out std_logic_vector(1 to 4) -- 4  Salidas simples, se declara F como un vector de 
	);
	end Cuadruple_NAND;

architecture simple of Cuadruple_NAND is 
  begin
    F <= A NAND B; --Compuertas NAND
  end simple;
