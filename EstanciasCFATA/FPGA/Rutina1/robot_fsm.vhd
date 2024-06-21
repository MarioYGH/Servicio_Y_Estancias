--Rutina
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
    type state_type is (idle, step1, step2, step3, step4, rest);
    signal state, next_state : state_type;
    signal counter : integer := 0;

    constant DELAY : integer := 128000; -- Ajustar este valor para el delay deseado

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
        elsif rising_edge(clk) then
            if counter = DELAY then
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

            when step1 =>
                -- Mover M1 adelante y M2 atrás
                posicion1 <= std_logic_vector(unsigned(posicion1) + 1);
                posicion2 <= std_logic_vector(unsigned(posicion2) - 1);
                next_state <= step2;

            when step2 =>
                -- Mover M3 adelante y M4 atrás
                posicion3 <= std_logic_vector(unsigned(posicion3) - 1);
                posicion4 <= std_logic_vector(unsigned(posicion4) + 1);
                next_state <= step3;

            when step3 =>
                -- Mover M1 atrás y M2 adelante
                posicion1 <= std_logic_vector(unsigned(posicion1) - 1);
                posicion2 <= std_logic_vector(unsigned(posicion2) + 1);
                next_state <= step4;

            when step4 =>
                -- Mover M3 atrás y M4 adelante
                posicion3 <= std_logic_vector(unsigned(posicion3) + 1);
                posicion4 <= std_logic_vector(unsigned(posicion4) - 1);
                next_state <= rest;

            when rest =>
                next_state <= idle;

            when others =>
                next_state <= idle;
        end case;
    end process;

end fsm_arch;
