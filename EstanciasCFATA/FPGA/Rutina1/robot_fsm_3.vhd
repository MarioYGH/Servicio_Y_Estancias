library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity robot_fsm is
    Port (
        clk : in std_logic; -- Señal de 50MHz del FPGA
        reset : in std_logic; -- Reset
        button : in std_logic; -- Botón para iniciar la secuencia
        servo1, servo2, servo3, servo4 : out std_logic -- Señales PWM de salida para los servos
    );
end robot_fsm;

architecture fsm_arch of robot_fsm is
    signal clk_128khz : std_logic;
    signal posicion1, posicion2, posicion3, posicion4 : std_logic_vector(6 downto 0);
    type state_type is (idle, step1, step2, step3, step4, step5, step6, step7, step8, rest);
    signal state, next_state : state_type;
    signal counter : integer := 0;

    -- Constantes de delay específicas para cada paso
    constant DELAY1 : integer := 50000000; -- 1 segundo
    constant DELAY2 : integer := 25000000; -- 0.5 segundos
    --constant DELAY3 : integer := 75000000; -- 1.5 segundos
    --constant DELAY : integer := 2500000; -- (50ms en este caso)
    signal delay_value : integer := 50000000; -- Valor de delay por defecto

    -- Posiciones iniciales
    constant INIT_POS1 : std_logic_vector(6 downto 0) := "0101001";
    constant INIT_POS2 : std_logic_vector(6 downto 0) := "0011000";
    constant INIT_POS3 : std_logic_vector(6 downto 0) := "0101111";
    constant INIT_POS4 : std_logic_vector(6 downto 0) := "1000011";

begin
    -- Instanciación del módulo del divisor de frecuencia
    clk_divider_inst : entity work.clk128kHz
        port map (
            clk => clk,
            reset => reset,
            clk_128khz => clk_128khz
        );

    -- Instanciación de los módulos del controlador PWM del servo
    servo1_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion1,
            servo => servo1
        );

    servo2_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion2,
            servo => servo2
        );

    servo3_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion3,
            servo => servo3
        );

    servo4_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion4,
            servo => servo4
        );

    -- Máquina de estados
    process (clk, reset)
    begin
        if reset = '1' then
            state <= idle;
            posicion1 <= INIT_POS1;
            posicion2 <= INIT_POS2;
            posicion3 <= INIT_POS3;
            posicion4 <= INIT_POS4;
            counter <= 0;
        elsif rising_edge(clk) then
            if counter = delay_value then
                state <= next_state;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process (state, button)
    begin
        case state is
            when idle =>
                if button = '1' then
                    next_state <= step1;
                else
                    next_state <= idle;
                end if;
                delay_value <= DELAY1;

            when step1 =>
                -- Mover M2 de su PI a 0000100
                posicion2 <= "0000100";
                posicion1 <= INIT_POS1;
                posicion3 <= INIT_POS3;
                posicion4 <= INIT_POS4;
                next_state <= step2;
                delay_value <= DELAY1;

            when step2 =>
                -- Mover M4 de su PI a 0010111, M2 en la posición anterior y el resto en su PI
                posicion4 <= "0010111";
                posicion2 <= "0000100";
                posicion1 <= INIT_POS1;
                posicion3 <= INIT_POS3;
                next_state <= step3;
                delay_value <= DELAY1;

            when step3 =>
                -- M2 de su posición anterior a 0001110
                posicion2 <= "0001110";
                posicion4 <= "0010111";
                posicion1 <= INIT_POS1;
                posicion3 <= INIT_POS3;
                next_state <= step4;
                delay_value <= DELAY4;

            when step4 =>
                -- M4 de su posición anterior a 0110111
                posicion4 <= "0110111";
                posicion2 <= "0001110";
                posicion1 <= INIT_POS1;
                posicion3 <= INIT_POS3;
                next_state <= step5;
                delay_value <= DELAY1;

            when step5 =>
                -- M1 de su PI a 0010111
                posicion1 <= "0010111";
                posicion2 <= "0001110";
                posicion3 <= INIT_POS3;
                posicion4 <= "0110111";
                next_state <= step6;
                delay_value <= DELAY1;

            when step6 =>
                -- M3 de su PI a 1111111
                posicion3 <= "1111111";
                posicion1 <= "0010111";
                posicion2 <= "0001110";
                posicion4 <= "0110111";
                next_state <= step7;
                delay_value <= DELAY2;

            when step7 =>
                -- M1 pasa a su PI
                posicion1 <= INIT_POS1;
                posicion2 <= "0001110";
                posicion3 <= "1111111";
                posicion4 <= "0110111";
                next_state <= step8;
                delay_value <= DELAY1;

            when step8 =>
                -- M2 y M4 pasan a su PI
                posicion2 <= INIT_POS2;
                posicion4 <= INIT_POS4;
                posicion1 <= INIT_POS1;
                posicion3 <= INIT_POS3;
                next_state <= rest;
                delay_value <= DELAY1; 

            when rest =>
                next_state <= idle;

            when others =>
                next_state <= idle;
        end case;
    end process;

end fsm_arch;
