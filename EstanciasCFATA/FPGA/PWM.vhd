-- Este código en VHDL genera múltiples señales PWM a una frecuencia específica (10 kHz) utilizando un FPGA.
-- En este caso, el diseño genera 4 señales PWM con diferentes ciclos de trabajo fijos: 5%, 50%, 95%, y 100%.

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity PWM is
    generic (
        N : integer := 4; -- Número de señales PWM (en este caso 4)
        MAX_COUNT : integer := 5000 -- Valor máximo del contador para 10kHz (ajustado)
    );
    port (
        clk : in std_logic; -- Señal de reloj del FPGA (por ejemplo, 50 MHz)
        reset : in std_logic; -- Señal de reset
        pwm_out : out std_logic_vector(N-1 downto 0) -- Salidas PWM
    );
end PWM;

architecture behavioral of PWM is
    signal cnt : unsigned(12 downto 0) := (others => '0'); -- Contador común para todas las señales PWM
    
    -- Definimos los ciclos de trabajo como una señal
    type pwm_array is array (N-1 downto 0) of unsigned(7 downto 0);
    signal duty_cycle_unsigned : pwm_array := (others => (others => '0')); -- Inicializamos en ceros
begin

    -- Asignar los ciclos de trabajo de forma fija
    process(reset, clk)
    begin
        if reset = '1' then
            duty_cycle_unsigned(0) <= to_unsigned(12, 8);  -- 5% de 255 = 12
            duty_cycle_unsigned(1) <= to_unsigned(127, 8); -- 50% de 255 = 127
            duty_cycle_unsigned(2) <= to_unsigned(242, 8); -- 95% de 255 = 242
            duty_cycle_unsigned(3) <= to_unsigned(255, 8); -- 100% de 255 = 255
        elsif rising_edge(clk) then
            -- Mantenemos los valores durante el funcionamiento normal
            duty_cycle_unsigned(0) <= to_unsigned(12, 8);
            duty_cycle_unsigned(1) <= to_unsigned(127, 8);
            duty_cycle_unsigned(2) <= to_unsigned(242, 8);
            duty_cycle_unsigned(3) <= to_unsigned(255, 8);
        end if;
    end process;

    -- Contador común para todas las señales PWM
    process (reset, clk)
    begin
        if (reset = '1') then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if (cnt = MAX_COUNT) then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    -- Generación de las señales PWM según los ciclos de trabajo
    process (cnt, duty_cycle_unsigned)
    begin
        for i in 0 to N-1 loop
            if (cnt < resize(duty_cycle_unsigned(i) * MAX_COUNT / 255, cnt'length)) then
                pwm_out(i) <= '1'; -- Mantener en alto si el contador es menor que el ciclo de trabajo
            else
                pwm_out(i) <= '0'; -- Poner en bajo si el contador es mayor o igual al ciclo de trabajo
            end if;
        end loop;
    end process;

end behavioral;
