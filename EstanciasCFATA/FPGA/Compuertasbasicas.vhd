library IEEE;
use ieee.std_logic_1164.all -- Libreria estandar 

entity Compuertas_basicas is
	port (
     A, B : in std_logic;                -- Entradas simples
     F    : out std_logic_vector(1 to 7) -- 7 Salidas simples, se declara F como un vector de 
	);
	end Compuertas_basicas;

architecture simple of Compuertas_basicas is 
  begin
    F(1) <= NOT A;      -- Compuerta NOT
    F(2) <= NOT B;      -- Compuerta NOT
    F(3) <= A NAND B;   -- Compuerta NAND
    F(4) <= A NOR B;    -- Compuerta NOR
    F(5) <= A AND B;    -- Compuerta AND
    F(6) <= A OR B;     -- Compuerta OR
    F(7) <= A XOR B;    -- Compuerta XOR
  end simple;
